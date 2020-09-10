//
//  NowPlayableError.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

enum NowPlayableError: LocalizedError {
    case noRegisteredCommands
    case cannotSetCategory(Error)
    case cannotActivateSession(Error)
    case cannotReactivateSession(Error)

    var errorDescription: String? {
        switch self {
        case .noRegisteredCommands: return "No registered commands"
        case .cannotSetCategory(let error): return "Could not set category. Error: \(error)"
        case .cannotActivateSession(let error): return "Could not activate session. Error: \(error)"
        case .cannotReactivateSession(let error): return "Could not reactive session. Error: \(error)"
        }
    }
}
