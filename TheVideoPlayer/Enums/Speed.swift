//
//  Speed.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-07.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import Foundation

/*
 Property which indicates the speed of the video

 Init:
 let normalSpeed = Speed.x1
 let doubleSpeed = Speed.x2
 let quadrupleSpeed = Speed.x4

 */
enum Speed {
    // Normal speed of the original video
    case x1
    // Two times faster than normal speed
    case x2
    // Four times faster than normal speed
    case x4
}
