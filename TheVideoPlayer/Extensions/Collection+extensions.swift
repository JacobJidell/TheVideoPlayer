//
//  Collection+extensions.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-17.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

extension Collection {
    subscript (safe index: Index?) -> Iterator.Element? {
        guard let index = index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}
