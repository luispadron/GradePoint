//
//  Constants.swift
//  GradePoint
//
//  Created by Luis Padron on 7/22/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import Foundation

/**
 This file contains any constants, usually strings for keys/notifications used throughout the app
 */

/// The default letter grades in order of the ranges below for non-plus scale
/// The default letter grades in order of the ranges below for plus scale
let kLetterGrades = [
    "A",
    "B",
    "C",
    "D",
    "F"
]

/// The default grading percentages and their ranges for non-plus scale, index 0 is A, index 1 is B, and so on
let kGradeLetterRanges = [
    90.00...Double.infinity,
    80.00...89.99,
    70.00...79.99,
    60.00...69.99,
    0.00...59.99
]

/// The default letter grades in order of the ranges below for plus scale
let kPlusScaleLetterGrades = [
    "A+",
    "A",
    "A-",
    "B+",
    "B",
    "B-",
    "C+",
    "C",
    "C-",
    "D+",
    "D",
    "D-",
    "F"
]

/// The default grading percentages and their ranges for plus scale, index 0 is A+, index 1 is A, and so on
let kPlusScaleGradeLetterRanges = [
    100...Double.infinity,
    93.00...100,
    90.00...92.99,
    87.00...89.99,
    83.00...86.99,
    80.00...82.99,
    77.00...79.99,
    73.00...76.99,
    70.00...72.99,
    67.00...69.99,
    63.00...66.99,
    60.00...62.99,
    0.00...59.99,
]

// User default keys
let kUserDefaultOnboardingComplete = "com.luispadron.GradePoint.onboardingComplete"
let kUserDefaultStudentType = "com.luispadron.GradePoint.studentType"
let kUserDefaultTerms = "com.luispadron.GradePoint.terms"
let kUserDefaultTheme = "com.luispadron.GradePoint.theme"
let kUserDefaultLastDateAskedRating = "com.luispadron.GradePoint.lastDateAsked"
let kUserDefaultHasAskedRating = "com.luispadron.GradePoint.hasAskedRating"
let kUserDefaultDecimalPlaces = "com.luispadron.GradePoint.roundingAmount"
let kUserDefaultGradeBirdHighScore = "com.luispadron.GradePoint.gradeBirdHighScore"
let kUserDefaultHasModifiedGradePercentages = "com.luispadron.GradePoint.hasModifiedGradePercentages"

// Notifications
let kSemestersUpdatedNotification = Notification.Name("com.luispadron.GradePoint.semestersUpdated")
let kThemeUpdatedNotification = Notification.Name("com.luispadron.GradePoint.themeUpdated")

// Custom URL's
let kGradePointOpenURL = URL(string: "gradePoint://com.luispadron.gradepoint.open")!
let kEmptyWidgetActionURL = URL(string: "gradePoint://com.luispadron.gradepoint.emptyWidgetAction")!

let kAdMobBannerTestId = "ca-app-pub-3940256099942544/2934735716"
let kAdMobInterstitalTestId = "ca-app-pub-3940256099942544/4411468910"

// Misc.
let kContactEmail = "heyluispadron@gmail.com"
let kGradePointGroupId = "group.com.luispadron.GradePoint"
let kGradePointPremiumProductId = "com.luispadron.GradePoint.GradePointPremium"

