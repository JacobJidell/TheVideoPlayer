//
//  AssetPlayer.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

class AssetPlayer {

    enum PlayerState {
        case playing
        case stopped
        case paused
    }

    let player: AVPlayer

    let behavior: NowPlayable

    private var playerState: PlayerState = .stopped

    // Observers
    private var playerTimerControlStatusObserver: NSKeyValueObservation?
    private var playerItemCanStepForwardObserver: NSKeyValueObservation?
    private var playerItemCanStepBackwardObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?

    // Handlers
    var onTimeControlStatusUpdate: ((AVPlayer) -> Void)?
    var onPeriodicTimeUpdate: ((CMTime, AVPlayer) -> Void)?
    var onFastForwardUpdate: ((_ playable: Bool) -> Void)?
    var onReverseUpdate: ((_ playable: Bool) -> Void)?
    var onStatusUpdate: ((AVPlayer) -> Void)?


    // Initialize player with the configurations
    init(configuration: Configuration = PlayerConfiguration.shared) throws {
        // Set the configuration playable behavior.
        behavior = configuration.behavior

        // Get the assets from the configuration and create AVPlayerItems from the urlAssets.
        let assets = configuration.assets.map { AVPlayerItem(asset: $0.urlAsset) }
        guard let firstAsset = assets.first else {
            throw PlayerError.noAssetFound
        }

        // Create a AVPlayer and configure it for external playback.
        self.player = AVPlayer(playerItem: firstAsset)
        self.player.allowsExternalPlayback = configuration.allowsExternalPlayback

        // Configure player for Now Playing info and Remote Command Center behaviors.
        try behavior.handleConfiguration(commands: [],
                                         disableCommands: [],
                                         commandHandler: handleCommand(command:event:),
                                         interuptionHandler: handleInteruption(interuption:))
    }
    /**
     Removes all current handlers
     */
    func removeAllHandlers() {
        onTimeControlStatusUpdate = nil
        onPeriodicTimeUpdate = nil
        onFastForwardUpdate = nil
        onReverseUpdate = nil
        onStatusUpdate = nil
    }

    func setupSession() throws {
        guard player.currentItem != nil else {
            throw PlayerError.noAssetFound
        }

        try behavior.handleNowPlayingSessionStart()

        addObservers()
    }

    private func addObservers() {
        /**
        Add an observer to toggle between pause/play to reflect
        the playback state of the AVPlayer's `timeControlStatus` property.
        */
        playerTimerControlStatusObserver = player.observe(\AVPlayer.timeControlStatus, options: [.initial, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            DispatchQueue.main.async { self.onTimeControlStatusUpdate?(player) }
        }

        let interval = CMTime(value: 1, timescale: 2)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
            guard let self = self else { return }
            DispatchQueue.main.async { self.onPeriodicTimeUpdate?(time, self.player) }
        })

        /**
         Create observeres to the players' properties `canStepForward` and `canStepBackward` to
         enable the corresponding buttons.
         */
        playerItemCanStepForwardObserver = player.observe(\AVPlayer.currentItem?.canPlayFastForward, options: [.initial, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            DispatchQueue.main.async { self.onFastForwardUpdate?(player.currentItem?.canPlayFastForward ?? false)}
        }

        playerItemCanStepBackwardObserver = player.observe(\AVPlayer.currentItem?.canPlayReverse, options: [.initial, .new]) { [weak self] (player, _) in
            guard let self = self else { return }
            DispatchQueue.main.async { self.onReverseUpdate?(player.currentItem?.canPlayReverse ?? false)}
        }

        /**
         Create an observer on the player's item property `status` to observe
         state changes as they occurs.
         */
        playerItemStatusObserver = player.observe(\AVPlayer.currentItem?.status, options: [.initial, .new], changeHandler: { [weak self] (player, _) in
            guard let self = self else { return  }
            DispatchQueue.main.async { self.onStatusUpdate?(self.player) }
        })
    }

    // MARK: - Remote commands

    private func handleCommand(command: NowPlayableCommand, event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        switch command {
        case .play: play()
        case .pause: pause()
        case .skipForward:
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }
            skipForward(by: event.interval)
        case .skipBackward:
            guard let event = event as? MPSkipIntervalCommandEvent else {
                return .commandFailed
            }
            skipBackward(by: event.interval)
        }
        return .success
    }

    // MARK: - Interuptions
    // typealias InteruptionHandler = (NowPlayableInterruption) -> Void

    private func handleInteruption(interuption: NowPlayableInterruption) {
        switch interuption {
        case .began: ()
        case .ended( _): ()
        case .failed( _): ()
        }
    }
}

// MARK: - Playback controls

extension AssetPlayer {
    private func play() {

    }

    private func pause() {

    }

    private func skipForward(by interval: TimeInterval) {

    }

    private func skipBackward(by interval: TimeInterval) {

    }
}
