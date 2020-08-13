//
//  ConfigCommand.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-13.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

class ConfigCommand {
    let command: NowPlayableCommand

    init(_ command: NowPlayableCommand) {
        self.command = command
    }
}
