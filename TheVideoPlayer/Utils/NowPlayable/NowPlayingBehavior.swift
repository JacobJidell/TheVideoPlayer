//
//  NowPlayableBehavior.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-12.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation
import AVFoundation

class NowPlayableBehavior: NowPlayable {
    static let shared = NowPlayableBehavior()

    // Observer for audio interruption
    var interruptionObserver: NSObjectProtocol!

    private var interruptionHandler: ((NowPlayableInterruption) -> Void)?

    func handleNowPlayingSessionStart() throws {
        let audioSession = AVAudioSession.sharedInstance()

        interruptionObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: audioSession, queue: .main, using: { [weak self] (notification) in
            guard let self = self else { return }


        })


        // Set audioSession category
        try audioSession.setCategory(.playback, mode: .moviePlayback, policy: .longFormVideo)
        // Make audioSession active
        try audioSession.setActive(true)
    }

    func handleNowPlayingSessionEnd() throws {
        // Stop observing interruptions to the audio session.
        interruptionObserver = nil

        // Make the audio session inactive
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session, error: \(error)")
        }
    }

    func handleConfiguration(commands: [NowPlayableCommand],
                             disableCommands: [NowPlayableCommand],
                             commandHandler: @escaping CommandHandler,
                             interruptionHandler: @escaping InterruptionHandler) throws {

        // Add handler
        self.interruptionHandler = interruptionHandler

        try configureRemoteCommands(commands: commands, disableCommands: disableCommands, commandHandler: commandHandler)
    }

    func handleNowPlayableItemChange(metadata: NowPlayableMetaData) {
        // Update Now Playing metadata
        updateNowPlayingMetaData(metadata)
    }
}
