//
//  VideoError.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-17.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

enum VideoError: LocalizedError {
    case videoDoesNotExist
    case invalidPath
    case failedToDecode(Error)
    case undetermined(Error)

    var errorDescription: String? {
        switch self {
        case .invalidPath: return "The path is invalid."
        case .videoDoesNotExist: return "The video does not exist."
        case .undetermined(let error): return "Failed with error: \(error)"
        case .failedToDecode(let error): return "Failed to decode: \(error) "
        }
    }
}
