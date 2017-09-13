//
//  RatingManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import StoreKit

/**
 RatingManager
 
 Used to easily handle any rating related taks, such as asking the user to rate the app or if the a rating should even
 be presented.
 */
class RatingManager {
    
    // MARK: Methods
    
    /// Presents a rating prompt to the user if possible.
    /// Returns a boolean of whether or not the rating dialog was presented.
    @discardableResult public static func presentRating() -> Bool {
        /// Since using built in rating available in 10.3, any iOS below that
        /// will not be allowed to show dialog.
        if #available(iOS 10.3, *) {
            let shouldPresent = RatingManager.shouldPresentRating()
            
            if shouldPresent {
                // Present rating dialog
                DispatchQueue.main.async {
                    SKStoreReviewController.requestReview()
                }
            }
            
            return shouldPresent
        } else {
            return false
        }
    }
    
    private static func dateDifference(start date1: Date, end date2: Date) -> Int {
        let calendar = Calendar.current
        guard let start = calendar.ordinality(of: .day, in: .era, for: date1) else { return 0 }
        guard let end = calendar.ordinality(of: .day, in: .era, for: date2) else { return 0 }
        
        return end - start
    }
    
    /// Whether the rating dialog should be presented to the user or not
    private static func shouldPresentRating() -> Bool {
        let lastDayAsked = UserDefaults.standard.object(forKey: userDefaultLastDateAsked) as? Date
        let hasAsked = UserDefaults.standard.bool(forKey: userDefaultHasAskedRating)
        // If user has info sessions, and classes/assignments/gpa calculation then we can present
        // the rating dialog
        let realm = DatabaseManager.shared.realm
        let classCount = realm.objects(Class.self).count
        let assignmentCount = realm.objects(Assignment.self).count
        let gpaCalcCount = realm.objects(GPACalculation.self).count
        let canAsk = AppDelegate.appInfo.sessions >= 5 && ((classCount >= 2 && assignmentCount >= 5) || gpaCalcCount >= 5)
        
        if (!hasAsked || abs(dateDifference(start: lastDayAsked ?? Date(), end: Date())) > 60) && canAsk {
            UserDefaults.standard.set(Date(), forKey: userDefaultLastDateAsked)
            UserDefaults.standard.set(true, forKey: userDefaultHasAskedRating)
            return true
        }
        
        return false
    }
    
    
}
