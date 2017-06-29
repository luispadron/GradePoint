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
    static let shared: RatingManager = RatingManager()
    static let appId = 1207588479
    
    func shouldPresentRating() -> Bool {
        return try! Realm().objects(Class.self).count > 0 ? true : false
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
    
    func update(with status: LPRatingViewCompletionStatus) {

    }
}
