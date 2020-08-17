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

    init(urlPath path: String, title: String) {
        guard let url = URL(string: path) else { fatalError() }
        self.assetURL = url
        self.title = title
    }

    init(assetURL: URL, title: String) {
        self.assetURL = assetURL
        self.title = title
    }
}

struct NowPlayableDynamicMetaData {
    var rate: Float
    var position: Float
    var duration: Float
}
