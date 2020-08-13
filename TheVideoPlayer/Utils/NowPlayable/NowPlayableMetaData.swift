//
//  NowPlayableMetaData.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

struct NowPlayableMetaData {
    let assetURL: URL
    let title: String
}

struct NowPlayableDynamicMetaData {
    var rate: Float
    var position: Float
    var duration: Float
}
