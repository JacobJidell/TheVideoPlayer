//
//  AssetPlayer.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation
import AVFoundation

class AssetPlayer {

    let player: AVPlayer

    let behavior: NowPlayable

    // Observers
    private var playerTimerControlStatusObserver: NSKeyValueObservation?
    private var playerItemCanStepForwardObserver: NSKeyValueObservation?
    private var playerItemCanStepBackwardObserver: NSKeyValueObservation?
    private var playerItemStatusObserver: NSKeyValueObservation?

    var handler: (() -> Void)?

    // Initialize player with the configurations
    init(configuration: Configuration = PlayerConfiguration.shared) throws {
        /**
         Set the configuration playable behavior.
         */
        behavior = configuration.behavior

        /**
         Get the assets from the configuration and create AVPlayerItems from the urlAssets.
         */
        let assets = configuration.assets.map { AVPlayerItem(asset: $0.urlAsset) }
        guard let firstAsset = assets.first else {
            throw PlayerError.noAssetFound
        }

        /**
         Create a AVPlayer and configure it for external playback.
         */
        self.player = AVPlayer(playerItem: firstAsset)
        self.player.allowsExternalPlayback = configuration.allowsExternalPlayback


//        try behavior.handleConfiguration(commands: <#T##[NowPlayableCommand]#>, disableCommands: <#T##[NowPlayableCommand]#>, commandHandler: <#T##CommandHandler##CommandHandler##(NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus#>, interuptionHandler: <#T##InteruptionHandler##InteruptionHandler##(NowPlayableInterruption) -> Void#>)
    }

    func addHandler() { }

    func optOut() {

    }
}
