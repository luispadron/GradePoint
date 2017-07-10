//
//  AppInfo.swift
//  GradePoint
//
//  Created by Luis Padron on 6/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift
/**
 Model used to store information about how many times user has been asked to rate the app.
 Will only ever exist one of these per application, per device.
 This will contain and track information related to how many times user was asked to rate, last time since asked, etc.
 */
class AppInfo: Object {
    // MARK: - Properties
    
    /// The primary id for the AppInfo object
    @objc dynamic var id: Int = 1
    /// The number of times the user has opened the app
    @objc dynamic var appSessions: Int = 0
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
