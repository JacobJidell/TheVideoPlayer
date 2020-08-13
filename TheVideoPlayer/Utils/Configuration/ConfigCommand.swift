//
//  ConfigCommand.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-13.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

struct ConfigCommand {
    let command: NowPlayableCommand

    init(_ command: NowPlayableCommand) {
        self.command = command
    }
}

struct ConfigCommandCollection {

    let commands: [ConfigCommand]

    init(commands: [ConfigCommand]) {
        self.commands = commands
    }
}
