//
//  RatingManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class RatingManager {
    /// The rating manager singelton/shared instance
    static let shared: RatingManager = RatingManager()
    /// The applications ID
    static let appId = 1207588479
    /// Returns the only AppInfo object stored in realm, if never created before, creates one and returns it
    private var appInfo: AppInfo {
        get {
            let realm = try! Realm()
            guard let info = realm.objects(AppInfo.self).first else {
                // Create an object, return it
                let newInfo = AppInfo()
                try! realm.write {
                    realm.create(AppInfo.self, value: newInfo, update: false)
                }
                return newInfo
            }
            return info
        }
    }
    
    // MARK: Public helper methods
    
    /// Whether the rating dialog should be presented to the user or not
    func shouldPresentRating() -> Bool {
        return true
    }
    
    /// Increments the appSessions count in the app info by 1
    func incrementSessions() {
        let realm = try! Realm()
        let info = self.appInfo
        if realm.isInWriteTransaction {
            info.appSessions += 1
        } else {
            try! realm.write {
                appInfo.appSessions += 1
            }
        }
    }
}
