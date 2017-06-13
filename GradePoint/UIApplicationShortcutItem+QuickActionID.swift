//
//  UIApplicationShortCutItem+QuickActionID.swift
//  GradePoint
//
//  Created by Luis Padron on 6/13/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

extension UIApplicationShortcutItem {
    var quickActionId: QuickActionId {
        get {
            if let id = QuickActionId(rawValue: self.type) {
                return id
            }else {
                return .unknown
            }
        }
    }
}
