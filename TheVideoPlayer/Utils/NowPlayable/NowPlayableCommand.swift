//
//  NowPlayableCommand.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation
import MediaPlayer

typealias CommandHandler = (NowPlayableCommand, MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus

enum NowPlayableCommand: CaseIterable {
    case play, pause, skipForward, skipBackward

    var remoteCommand: MPRemoteCommand {
        let remoteCommandCenter = MPRemoteCommandCenter.shared()

        switch self {
        case .play: return remoteCommandCenter.playCommand
        case .pause: return remoteCommandCenter.pauseCommand
        case .skipForward: return remoteCommandCenter.skipForwardCommand
        case .skipBackward: return remoteCommandCenter.skipBackwardCommand
        }
    }

    // Removes command target
    func removeHandler() {
        remoteCommand.removeTarget(nil)
    }

    func add(_ handler: @escaping CommandHandler) {
        switch self {
        case .skipForward: MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals = [10]
        case .skipBackward: MPRemoteCommandCenter.shared().skipBackwardCommand.preferredIntervals = [10]
        default: break
        }

        remoteCommand.addTarget { handler(self, $0) }
    }
    
    func setDisabled(_ isDisabled: Bool) {
        remoteCommand.isEnabled = !isDisabled
    }
}
