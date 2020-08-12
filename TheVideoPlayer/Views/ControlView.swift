//
//  ControlView.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-07.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import UIKit
import AVKit

protocol ControlDelegate: class {
    func didPressPlayPause()
    func didPressForward()
    func didPressRewind()
    func didPressReverse()
    func didPressFastForward()
    func didSlideTimer(with seconds: Double)
}

class ControlView: UIView {
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!

    weak var delegate: ControlDelegate?

    lazy var timeRemainingFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        return formatter
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        roundCorners()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        roundCorners()
    }
}

extension ControlView {
    // MARK: - Update UI
    func setPlayPauseButtonIcon(with player: AVPlayer) {
        let buttonImage: UIImage?
        switch player.timeControlStatus {
        case .playing: buttonImage = UIImage(systemName: "pause.fill")
        case .paused, .waitingToPlayAtSpecifiedRate: buttonImage = UIImage(systemName: "play.fill")
        @unknown default: buttonImage = UIImage(systemName: "pause.fill")
        }
        guard let image = buttonImage else {
            return
        }
        playPauseButton.setImage(image, for: .normal)
    }

    func updateUIForControl(with player: AVPlayer) {
        guard let item = player.currentItem else { return }

        switch item.status {
        case .readyToPlay:
            playPauseButton.isEnabled = true

            let durationInSeconds = Float(item.duration.seconds)
            let currentTime = Float(CMTimeGetSeconds(player.currentTime()))

            timeSlider.maximumValue = durationInSeconds
            timeSlider.value = currentTime
            timeSlider.isEnabled = true
            remainingTimeLabel.text = createTimeString(time: durationInSeconds)
            currentTimeLabel.text = createTimeString(time: currentTime)

        case .failed:
            playPauseButton.isEnabled = false
            timeSlider.isEnabled = false
        default: playPauseButton.isEnabled = true
        }
    }

    func updateUIForSlider(with time: CMTime, player: AVPlayer) {
        let timeElapsed = Float(time.seconds)
        timeSlider.value = timeElapsed
        currentTimeLabel.text = createTimeString(time: timeElapsed)

        guard let item = player.currentItem else { return }
        let durationInSeconds = Float(item.duration.seconds)
        let remainingInSeconds = durationInSeconds - timeElapsed
        remainingTimeLabel.text = createTimeString(time: remainingInSeconds)
    }

    private func roundCorners() {
        self.layer.cornerRadius = 8
    }

    // MARK: - Private functions

    private func createTimeString(time: Float) -> String {
        let components = NSDateComponents()
        components.second = Int(max(0.0, time))
        return timeRemainingFormatter.string(from: components as DateComponents)!
    }

    // MARK: - IBActions
    @IBAction func didPressPlay(_ sender: UIButton) {
        delegate?.didPressPlayPause()
    }

    @IBAction func didPressForward(_ sender: UIButton) {
        delegate?.didPressForward()
    }

    @IBAction func didPressRewind(_ sender: UIButton) {
        delegate?.didPressRewind()
    }

    @IBAction func didPressReverse(_ sender: UIButton) {
        delegate?.didPressReverse()
    }

    @IBAction func didPressFastForward(_ sender: UIButton) {
        delegate?.didPressFastForward()
    }

    @IBAction func didSlideTime(_ sender: UISlider) {
        delegate?.didSlideTimer(with: Double(sender.value))
    }
}
