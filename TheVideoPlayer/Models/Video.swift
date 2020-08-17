//
//  Video.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-17.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

// MARK: - Categories
struct Categories: Codable {
    let name: String
    let videos: [Video]
}

// MARK: - Video
struct Video: Codable {
    let videoDescription: String
    let sources: [String]
    let subtitle: Subtitle
    let thumb, title: String

    enum CodingKeys: String, CodingKey {
        case videoDescription = "description"
        case sources, subtitle, thumb, title
    }
}

enum Subtitle: String, Codable {
    case byBlenderFoundation = "By Blender Foundation"
    case byGarage419 = "By Garage419"
    case byGoogle = "By Google"
}

