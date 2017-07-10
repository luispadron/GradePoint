//
//  RatingManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

/**
 RatingManager
 
 Used to easily handle any rating related taks, such as asking the user to rate the app or if the a rating should even
 be presented.
 */
class RatingManager {
    
    // MARK: Methods
    
    /// Whether the rating dialog should be presented to the user or not
    public static func shouldPresentRating() -> Bool {
        // If user has info sessions, and classes/assignments/gpa calculation then we can present
        // the rating dialog
        let realm = try! Realm()
        let classCount = realm.objects(Class.self).count
        let assignmentCount = realm.objects(Assignment.self).count
        let gpaCalcCount = realm.objects(GPACalculation.self).count
        return AppDelegate.appInfo.sessions > 5 && ((classCount > 2 && assignmentCount > 5) || gpaCalcCount > 5)
    }
    
}
