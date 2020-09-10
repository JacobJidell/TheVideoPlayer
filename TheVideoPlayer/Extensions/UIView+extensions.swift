//
//  UIView+extensions.swift
//  TheVideoPlayer
//
//  Created by Jacob Ahlberg on 2020-08-14.
//  Copyright © 2020 Knowit Mobile. All rights reserved.
//

import UIKit

extension UIView {
    enum State {
        case hide, show
    }

    func fade(should state: State, onCompletion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = state == .hide ? 0 : 1
        }, completion: onCompletion)
    }
}
