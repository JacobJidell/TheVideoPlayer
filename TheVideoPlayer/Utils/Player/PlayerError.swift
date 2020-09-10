//
//  PlayerError.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-07.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

enum PlayerError: LocalizedError {
    case notPlayable
    case noAssetFound
    case failed
}
