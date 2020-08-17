//
//  Configuration.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

protocol Configuration {
    // Behavior conforming to the NowPlayable protocol
    var behavior: NowPlayable { get }
    // Allows external playback
    var allowsExternalPlayback: Bool { get set }
    // Assets
    var assets: [ConfigurationAsset] { get set }
    // Collection of commands
    var commandCollections: [ConfigCommandCollection] { get set }
}

struct PlayerConfiguration: Configuration {
    static var shared = PlayerConfiguration()

    let behavior: NowPlayable

    var allowsExternalPlayback = true
    var assets: [ConfigurationAsset] = []
    var commandCollections: [ConfigCommandCollection] = []

    // Initialize a new configuration
    init(behavior: NowPlayable = NowPlayableBehavior.shared) {
        self.behavior = behavior
        self.assets = defaultAssets
        self.commandCollections = defaultCommandCollections
    }

    init (assets: [ConfigurationAsset], behavior: NowPlayable = NowPlayableBehavior.shared) {
        self.behavior = behavior
        self.assets = assets
        self.commandCollections = defaultCommandCollections
    }
}

extension PlayerConfiguration {
    private var defaultAssets: [ConfigurationAsset] {
        guard let url = URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4") else {
            fatalError("Video was not found")
        }
        let metaData = NowPlayableMetaData(assetURL: url, title: "Big Buck Bunny")

        
        return [ConfigurationAsset(metaData)]
    }

    private var defaultCommandCollections: [ConfigCommandCollection] {
        let commands = [
            ConfigCommand(.play),
            ConfigCommand(.pause),
            ConfigCommand(.skipBackward),
            ConfigCommand(.skipForward),
        ]
        let commandsCollection = [
            ConfigCommandCollection(commands: commands)
        ]
        return commandsCollection
    }
}
