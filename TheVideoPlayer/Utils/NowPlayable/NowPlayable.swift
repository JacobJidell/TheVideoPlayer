//
//  NowPlayable.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation
import MediaPlayer

enum NowPlayableInterruption {
    case began, ended(Bool), failed(Error)
}

typealias InteruptionHandler = (NowPlayableInterruption) -> Void

protocol NowPlayable: class {
    func handleConfiguration(commands: [NowPlayableCommand],
                             disableCommands: [NowPlayableCommand],
                             commandHandler: @escaping CommandHandler,
                             interuptionHandler: @escaping InteruptionHandler) throws

    func handleNowPlayingSessionStart() throws
}

extension NowPlayable {
    func configureRemoteCommands(commands: [NowPlayableCommand],
                                 disableCommands: [NowPlayableCommand],
                                 commandHandler: @escaping CommandHandler) throws {
        // Make sure there's at least one command
        guard !commands.isEmpty else {
            throw NowPlayableError.noRegisteredCommands
        }

        // Configure all commands
        NowPlayableCommand.allCases.forEach( {
            // Remove existing handler
            $0.removeHandler()

            // Add handler if neccessary
            if commands.contains($0) {
                $0.add(commandHandler)
            }

            // Disable command if neccessary
            $0.setDisabled(disableCommands.contains($0))
        })
    }

    func updateNowPlayingMetaData(_ metaData: NowPlayableMetaData) {
        var nowPlayingInfo: [String: Any] = [:]
        nowPlayingInfo[MPNowPlayingInfoPropertyAssetURL] = metaData.assetURL
        nowPlayingInfo[MPMediaItemPropertyTitle] = metaData.title

        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }

    func updateNowPlayingPlayBackInfo(_ metaData: NowPlayableDynamicMetaData) {
        let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = metaData.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = metaData.position
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = metaData.rate
        nowPlayingInfo[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0

        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
}
