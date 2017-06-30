//
//  RatingManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import LPIntegratedRating

class RatingManager {
    /// The rating manager singelton/shared instance
    static let shared: RatingManager = RatingManager()
    /// The applications ID
    static let appId = 1207588479
    /// Returns the only RatingInfo object stored in realm, if never created before, creates one and returns it
    private var ratingInfo: RatingInfo {
        get {
            let realm = try! Realm()
            guard let info = realm.objects(RatingInfo.self).first else {
                // Create an object, return it
                let newInfo = RatingInfo()
                try! realm.write {
                    realm.create(RatingInfo.self, value: newInfo, update: false)
                }
                return newInfo
            }
            return info
        }
    }
    
    // MARK: Public helper methods
    
    /// Whether the rating dialog should be presented to the user or not
    func shouldPresentRating() -> Bool {
        switch ratingInfo.lastStatus {
        case .neverAsked:
            return shouldAskFirstTime()
        case .ratingAllowed:
            return shouldAskAfterRating()
        case .ratingRejected:
            return shouldAskAfterRatingRejected()
        case .feedbackAllowed:
            return shouldAskAfterFeedback()
        case .feedbackRejected:
            return shouldAskAfterFeedbackRejected()
        }
    }
    
    /// Updates the rating manager on the final status
    func update(with status: LPRatingViewCompletionStatus) {
        
    }
    
    /// Opens the appstore allowing the user to rate the app
    func openAppStore() {
        // let reviewUrl = "itms-apps://itunes.apple.com/app/id\(RatingManager.appId)?action=write-review"
        let reviewUrl = "itms-apps://itunes.apple.com/app/id\(RatingManager.appId)"
        if let url = URL(string: reviewUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    /// Opens the mail client if it can, if not lets the user know where to contact for feedback
    func openFeedback(ontop controller: UIViewController) {
        let presentError = {
            controller.presentErrorAlert(title: "Unable to email",
                                         message: "Couldn't open email client.\nFeel free to email me at LuisPadronn@gmail.com")
        }
        
        let toEmail = "luispadronn@gmail.com"
        if let subject = "Feedback For GradePoint".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: "mailto:\(toEmail)?subject=\(subject)") {
            
            if !UIApplication.shared.openURL(url) {
                presentError()
            }
            
        } else {
            presentError()
        }
    }
    
    /// Increments the appSessions count on the rating info by 1
    func incrementSessions() {
        let realm = try! Realm()
        let info = self.ratingInfo
        if realm.isInWriteTransaction {
            info.appSessions += 1
        } else {
            try! realm.write {
                ratingInfo.appSessions += 1
            }
        }
    }
    
    // MARK: Private helper methods/values
    
    /// Returns the day since the user was last asked to rate
    var daysSinceAsked: Int?  {
        get {
            guard let askDate = ratingInfo.lastAsked else {
                return nil
            }
            
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: askDate, to: Date())
            return components.day
        }
    }
    
    /// Returns whether user should be asked to rate, if this is the first time asking them
    private func shouldAskFirstTime() -> Bool {
        let classCount = try! Realm().objects(Class.self).count
        let assignmentCount = try! Realm().objects(Assignment.self).count
        let gpaCalcsCount = try! Realm().objects(GPACalculation.self).count
        
        let passesCounts = (classCount >= 3 && assignmentCount >= 5) || gpaCalcsCount >= 10
        
        return passesCounts && ratingInfo.appSessions >= 5
    }
    
    /// Returns whether user should be asked to rate, if they have already rated the app
    private func shouldAskAfterRating() -> Bool {
        return false
    }
    
    /// Returns whether user should be asked to rate, if they have rejected rating before
    private func shouldAskAfterRatingRejected() -> Bool {
        return false
    }
    
    /// Returns whether user should be asked to rate, if they have submitted feedback
    private func shouldAskAfterFeedback() -> Bool {
        return false
    }
    
    /// Returns whether user should be asked to rate, if they rejected to submit feedback
    private func shouldAskAfterFeedbackRejected() -> Bool {
        return false
    }
    
    
}
