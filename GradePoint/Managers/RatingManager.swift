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
    static let shared: RatingManager = RatingManager()
    static let appId = 1207588479
    
    func shouldPresentRating() -> Bool {
        return try! Realm().objects(Class.self).count > 0 ? true : false
    }
    
    func openAppStore() {
//        let reviewUrl = "itms-apps://itunes.apple.com/app/id\(RatingManager.appId)?action=write-review"
        let reviewUrl = "itms-apps://itunes.apple.com/app/id\(RatingManager.appId)"
        if let url = URL(string: reviewUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
}
