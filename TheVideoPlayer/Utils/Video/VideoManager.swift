//
//  VideoManager.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-17.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

class VideoManager {
    static func fetchVideos() throws -> [Video] {
        guard let videoPath = Bundle.main.path(forResource: "videos", ofType: ".json") else { throw VideoError.invalidPath }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: videoPath)) else { throw VideoError.videoDoesNotExist }

        do {
            let categories = try JSONDecoder().decode(Categories.self, from: data)
            return categories.videos
        } catch {
            throw VideoError.failedToDecode(error)
        }
    }
}

