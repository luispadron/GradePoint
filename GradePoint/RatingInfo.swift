//
//  RatingInfo.swift
//  GradePoint
//
//  Created by Luis Padron on 6/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// Enum which will be used to determine the status the user has selected when rating
/// Basically `LPRatingViewCompletionStatus`, but conformed to work with Realm and more sense in this context
@objc enum RatingStatus: Int {
    case neverAsked = 0
    case ratingAllowed = 1
    case ratingRejected = 2
    case feedbackAllowed = 3
    case feedbackRejected = 4
}

/**
 Model used to store information about how many times user has been asked to rate the app.
 Will only ever exist one of these per application, per device.
 This will contain and track information related to how many times user was asked to rate, last time since asked, etc.
 */
class RatingInfo: Object {
    // MARK: - Properties
    
    /// The primary id for the RatingInfo object
    @objc dynamic var id: Int = 1
    /// The number of times the user has opened the app
    @objc dynamic var appSessions: Int = 0
    /// The amount of times the user has been asked to rate the app
    @objc dynamic var timesAsked: Int = 0
    /// The last date the user was asked to rate the app
    @objc dynamic var lastAsked: Date? = nil
    /// The last app version the user was asked to rate
    @objc dynamic var lastAppVersion: String? = nil
    /// The last status of the user when asked to rate
    @objc dynamic var lastStatus: RatingStatus = .neverAsked
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
