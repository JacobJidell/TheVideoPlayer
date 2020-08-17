//
//  VideoViewController.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-07.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class VideoViewController: UIViewController {
    static func create(video: Video) -> VideoViewController? {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: VideoViewController.identifier) as? VideoViewController else {
            return nil
        }
        vc.video = video
        return vc
    }

    static var identifier = "VideoViewController"

    @IBOutlet weak var playerView: PlayerView!
    // For airplay
    @IBOutlet weak var videoSettingsContainerView: UIView!
    @IBOutlet weak var airplayContainerView: UIView!
    // For custom controllers
    @IBOutlet weak var controlView: ControlView!

    // Airplay AVRoutePickerView
    private var routePicker: AVRoutePickerView {
        let routePicker = AVRoutePickerView()
        routePicker.prioritizesVideoDevices = true
        routePicker.frame = .init(x: 0, y: 0, width: 44, height: 44)
        routePicker.tintColor = .white
        routePicker.activeTintColor = #colorLiteral(red: 0.03529411765, green: 0.5176470588, blue: 1, alpha: 1)
        return routePicker
    }

    // To get the current orientation of device
    private var statusBarOrientation: UIInterfaceOrientation {
        get {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                fatalError("Could not find orientation")
            }
            return orientation
        }
    }
    private var shouldRotate = false
    override var shouldAutorotate: Bool { return shouldRotate }

    // Hide home indicator upon rotation
    override var prefersHomeIndicatorAutoHidden: Bool { isNavigationBarHidden }
    private var isNavigationBarHidden = false {
        didSet {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
    }

    private var video: Video!
    private var assetPlayer: AssetPlayer!
    private var fadeOutTimer: Timer?
    private var tapGesture: UITapGestureRecognizer?

    // MARK: - Video key value observers

    private var playerTimerControlStatusObserver: NSKeyValueObservation?
    private var playerItemCanStepForwardObserver: NSKeyValueObservation?
    private var playerItemCanStepBackwardObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?

    private var timeObserverToken: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        controlView.delegate = self
        setupAirPlay()
        setupAssetPlayer()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        switch statusBarOrientation {
        case .landscapeRight:
            navigationController?.setNavigationBarHidden(false, animated: true)
            isNavigationBarHidden = false
        case .portrait:
            navigationController?.setNavigationBarHidden(true, animated: true)
            isNavigationBarHidden = true
        default: break
        }
    }

    @IBAction func didPressEnterFullScreenCustom(_ sender: UIButton) {
        shouldRotate.toggle()
        UIDevice.current.setValue(statusBarOrientation == .portrait ? UIInterfaceOrientation.landscapeRight.rawValue :
            UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()

        sender.setImage(UIImage(systemName: statusBarOrientation == .portrait ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left"), for: .normal)
        shouldRotate.toggle()

        if statusBarOrientation == .landscapeRight {
            resetTimer()

            let tap = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
            self.tapGesture = tap
            self.playerView.addGestureRecognizer(tap)
        } else {
            if let tapGesture = tapGesture {
                self.playerView.removeGestureRecognizer(tapGesture)
                self.tapGesture = nil
            }
            showControls()
            fadeOutTimer?.invalidate()
            fadeOutTimer = nil
        }
    }

    // MARK: - Timer & Controls

    private func resetTimer() {
        fadeOutTimer?.invalidate()
        fadeOutTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(hideControls), userInfo: nil, repeats: false)
    }

    @objc
    private func toggleControls() {
        let isHidden = controlView.isHidden
        if isHidden {
            controlView.isHidden = false
            videoSettingsContainerView.isHidden = false
        }
        controlView.fade(should: isHidden ? .show : .hide) { _ in
            if !isHidden {
                self.controlView.isHidden = true
            }
        }

        videoSettingsContainerView.fade(should: isHidden ? .show : .hide) { _ in
            if !isHidden {
                self.videoSettingsContainerView.isHidden = true
            }
        }
        
        resetTimer()
    }

    // MARK: - Setup

    private func setupAssetPlayer() {
        do {
            // Create an asset from the video
            let asset = ConfigurationAsset(NowPlayableMetaData(urlPath: video.source, title: video.title))

            // Create player configuration
            let configuration = PlayerConfiguration(assets: [asset])

            // Create an AssetPlayer
            assetPlayer = try AssetPlayer(configuration: configuration)

            /**
            Add/Replace the current player in the `playerView`.
            The `AVPlayer` and `AVPlayerItem` are not a visible objects. Use the `AVPlayerLayer`
            object to manage visual output.
            */
            playerView.player = assetPlayer.player

            /**
             Connect to the handlers. As soon an update occurs the corresponding
             handler will be triggered.
             */
            assetPlayer.onTimeControlStatusUpdate = { [weak self] player in
                guard let self = self else { return }
                /**
                 Configure the image for the `playPauseButton` depending on the
                 players' property `timeControlStatus`.
                 */
                self.controlView.setPlayPauseButtonIcon(with: player)
            }

            assetPlayer.onPeriodicTimeUpdate = { [weak self] (time, player) in
                guard let self = self else { return }
                self.controlView.updateUIForSlider(with: time, player: player)
            }

            assetPlayer.onFastForwardUpdate = { [weak self] playable in
                guard let self = self else { return }
                self.controlView.fastForwardButton.isEnabled = playable

            }

            assetPlayer.onReverseUpdate = { [weak self] playable in
                guard let self = self else { return }
                self.controlView.reverseButton.isEnabled = playable
            }

            assetPlayer.onStatusUpdate = { [weak self] player in
                guard let self = self else { return }
                // Configure the UI for the controlView
                self.controlView.updateUIForControl(with: player)
            }

            // Start session
            try assetPlayer.setupSession()
        } catch {
            print(error)
        }
    }

    // Adding the AVRoutePickerView to the containerView.
    private func setupAirPlay() {
        airplayContainerView.addSubview(routePicker)
    }

    // MARK: - UI

    @objc
    private func hideControls() {
        controlView.fade(should: .hide) { _ in
            self.controlView.isHidden = true
        }

        videoSettingsContainerView.fade(should: .hide) { _ in
            self.videoSettingsContainerView.isHidden = true
        }
    }

    private func showControls() {
        controlView.isHidden = false
        controlView.alpha = 1
        videoSettingsContainerView.isHidden = false
        videoSettingsContainerView.alpha = 1
    }
}

extension VideoViewController: ControlDelegate {
    func didPressPlayPause() {
        assetPlayer.play()
    }

    func didPressFastForward() {
        assetPlayer.fastForward()
    }

    func didPressReverse() {
        assetPlayer.reverse()
    }

    func didPressForward() {
        assetPlayer.skip(by: 10)
    }

    func didPressRewind() {
        assetPlayer.skip(by: -10)
    }

    func didSlideTimer(with seconds: Double) {
        assetPlayer.adjustTime(with: seconds)
    }
}
