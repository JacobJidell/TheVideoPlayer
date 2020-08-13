//
//  NowPlayableBehavior.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

class NowPlayableBehavior: NowPlayable {
    static let shared = NowPlayableBehavior()
    
    func handleConfiguration(commands: [NowPlayableCommand], disableCommands: [NowPlayableCommand], commandHandler: @escaping CommandHandler, interuptionHandler: @escaping InteruptionHandler) throws {
        
    }

    func handleNowPlayingSessionStart() throws {

    }
}
