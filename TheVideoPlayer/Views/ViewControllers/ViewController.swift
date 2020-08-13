//
//  ViewController.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-07.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import MediaPlayer

class ViewController: UIViewController {
    @IBOutlet weak var playerView: PlayerView!
    // For airplay
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

    let player = AVPlayer()

    var assetPlayer: AssetPlayer!

    // MARK: - Video key value observers

    private var playerTimerControlStatusObserver: NSKeyValueObservation?
    private var playerItemCanStepForwardObserver: NSKeyValueObservation?
    private var playerItemCanStepBackwardObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?

    private var timeObserverToken: Any?

    enum Direction {
        case forward, rewind

        var value: Double {
            switch self {
            case .forward: return 10
            case .rewind: return -10
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        controlView.delegate = self
//        setupAsset()
        setupAirPlay()
        setup()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.view.setNeedsUpdateConstraints()
    }
    
    @IBAction func didPressPlayFullScreen(_ sender: Any) {
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            debugPrint("Video was not found")
            return
        }

        // Create an AVPlayer and insert the given url
        let player = AVPlayer(url: url)
        // Create an AVPlayerViewController and pass it a reference to the AVPlayer
        let controller = AVPlayerViewController()
        controller.player = player
        // Present the controller modally and start the player if wanted.
        present(controller, animated: true) {
            player.play()
        }
    }

    @IBAction func didPressEnterFullScreenCustom(_ sender: UIButton) {
//        arrow.up.left.and.arrow.down.right
        shouldRotate.toggle()
        UIDevice.current.setValue(statusBarOrientation == .portrait ? UIInterfaceOrientation.landscapeRight.rawValue :
            UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()

        sender.setImage(UIImage(systemName: statusBarOrientation == .portrait ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left"), for: .normal)
        shouldRotate.toggle()
    }


    // MARK: - Setup

    private func setup() {
        do {
            // Create an AssetPlayer
            assetPlayer = try AssetPlayer()

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

    /**
     Adding the AVRoutePickerView to the containerView inside a stackView.
     */
    private func setupAirPlay() {
        airplayContainerView.addSubview(routePicker)
    }

    private func setupAsset() {
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            debugPrint("Video was not found")
            return
        }

        // Create the AVAsset with the given URL
        let asset = AVAsset(url: url)

        let assetsKeys = [
        // If the `playable` property value equals `true`, then you can initialize an instance of the player item.
        "playable",
        // If the `hasProtectedContent` property value equals `true`, then the asset is protected and won't be playable
        "hasProtectedContent"
        ]

        asset.loadValuesAsynchronously(forKeys: assetsKeys) {
            DispatchQueue.main.async { self.handle(asset, with: assetsKeys) }
        }
    }

    private func handle(_ asset: AVAsset, with keys: [String]) {
        do {
            try validateValues(keys: keys, for: asset)
            /**
             Setup key-value observers on the player to
             update the user interface as changes occurs.
             */
            setupObservers()

            /**
             Add/Replace the current player in the `playerView`.
             The `AVPlayer` and `AVPlayerItem` are not a visible objects. Use the `AVPlayerLayer`
             object to manage visual output.
             */
            self.playerView.player = self.player

            /**
             Replace the current `AVPlayerItem` with the new asset. This will trigger the
             observation for the `currentItem` property `status`, which will be handled.
             */
            self.player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
        } catch {
            debugPrint("Something went wrong: \(error)")
        }
    }

    
    /**
     Confirm all the asset's keys and verify their values
     */
    private func validateValues(keys assetsKeys: [String], for asset: AVAsset) throws {
        for key in assetsKeys {
            var error: NSError?
            guard asset.statusOfValue(forKey: key, error: &error) == .failed else {
                continue
            }
            // Handle error
            throw PlayerError.failed
        }

        if !asset.isPlayable || asset.hasProtectedContent {
            /**
             The asset is not playable. Either the asset cannot initialize a player item, or the content is protected.
             */
            throw PlayerError.notPlayable
        }
    }

    private func setupObservers() {
        /**
         Add an observer to toggle between pause/play to reflect
         the playback state of the AVPlayer's `timeControlStatus` property.
         */
        playerTimerControlStatusObserver = player.observe(\AVPlayer.timeControlStatus, options: [.initial, .new], changeHandler: { [weak self] (player, _) in
            guard let self = self else { return }
            /**
             Configure the image for the `playPauseButton` depending on the
             players' property `timeControlStatus`.
             */
            DispatchQueue.main.async {
                self.controlView.setPlayPauseButtonIcon(with: player)
            }
        })

        let interval = CMTime(value: 1, timescale: 2)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
            guard let self = self else { return }
            self.controlView.updateUIForSlider(with: time, player: self.player)
        })

        /**
         Create observeres to the players' properties `canStepForward` and `canStepBackward` to
         enable the corresponding buttons.
         */
        playerItemCanStepForwardObserver = player.observe(\AVPlayer.currentItem?.canPlayFastForward, options: [.initial, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.controlView.fastForwardButton.isEnabled = player.currentItem?.canPlayFastForward ?? false
            }
        }

        playerItemCanStepBackwardObserver = player.observe(\AVPlayer.currentItem?.canPlayReverse, options: [.initial, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.controlView.reverseButton.isEnabled = player.currentItem?.canPlayReverse ?? false
            }
        }

        /**
         Create an observer on the player's item property `status` to observe
         state changes as they occurs.
         */
        playerItemStatusObserver = player.observe(\AVPlayer.currentItem?.status, options: [.initial, .new], changeHandler: { [weak self] (player, _) in
            guard let self = self else { return  }
            /**
             Configure the UI for the controlView
             */
            self.controlView.updateUIForControl(with: player)
        })
    }
}

extension ViewController: ControlDelegate {
    func didPressPlayPause() {
        switch player.timeControlStatus {
        case .playing:
            // If the player is currently playing, then pause.
            player.pause()
        case .paused:
            /**
             If the `currentItem` already has reached its end time, then revert back
             to the beginning
             */
            if (player.currentItem?.currentTime() ?? .zero) >= (player.currentItem?.duration ?? .zero) {
                player.currentItem?.seek(to: .zero, completionHandler: nil)
            }
            player.play()
        default: player.pause()
        }
    }

    func didPressFastForward() {
        /**
        If the `currentItem` already has reached its end time, then revert back
        to the beginning
        */
        if (player.currentItem?.currentTime() ?? .zero) >= (player.currentItem?.duration ?? .zero) {
            player.currentItem?.seek(to: .zero, completionHandler: nil)
        }
        // Play fast forward no faster than 2
        player.rate = min(player.rate + 2, 2)
    }

    func didPressReverse() {
        // Play reverse no faster than -2
        player.rate = max(player.rate - 2, -2)
    }

    func didPressForward() {
        player.currentItem?.seek(to: getNewTime(.forward), completionHandler: nil)
    }

    func didPressRewind() {
        player.currentItem?.seek(to: getNewTime(.rewind), completionHandler: nil)
    }

    func didSlideTimer(with seconds: Double) {
        let newTime = CMTime(seconds: seconds, preferredTimescale: 600)
        player.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }

    /**
     Returns a new time depending on if jumping forward or rewinding back 10 seconds.

     - Parameter direction: Chooses between either forward(+10 seconds) or rewind (-10 seconds).
     - Returns: An updated time which either will be 10 seconds forward or rewind of current time.
     */
    private func getNewTime(_ direction: Direction) -> CMTime {
        let currentTime = player.currentItem?.currentTime() ?? .zero
        let currentTimeInSecondsPlusDirection = CMTimeGetSeconds(currentTime).advanced(by: direction.value)
        return CMTime(value: CMTimeValue(currentTimeInSecondsPlusDirection), timescale: 1)
    }
}
