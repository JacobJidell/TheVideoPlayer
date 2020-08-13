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
}

struct PlayerConfiguration: Configuration {
    static var shared = PlayerConfiguration()

    let behavior: NowPlayable

    var allowsExternalPlayback = true
    // Assets
    var assets: [ConfigurationAsset] = []

    // Initialize a new configuration
    init(behavior: NowPlayable = NowPlayableBehavior.shared) {
        self.behavior = behavior
        self.assets = defaultAssets
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

    private var collectionCommands: [String] {
//        let collection = 
        return [String]()
    }
}
