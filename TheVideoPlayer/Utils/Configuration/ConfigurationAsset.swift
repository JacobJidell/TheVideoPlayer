//
//  ConfigurationAsset.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation
import AVFoundation

class ConfigurationAsset {
    let urlAsset: AVURLAsset
    let metaData: NowPlayableMetaData

    var shouldPlay = true

    init(_ metaData: NowPlayableMetaData) {
        urlAsset = AVURLAsset(url: metaData.assetURL)
        self.metaData = metaData
    }
}
