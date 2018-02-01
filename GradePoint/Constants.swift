//
//  Constants.swift
//  GradePoint
//
//  Created by Luis Padron on 7/22/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/// Any constants, usually strings for keys/notifications used throughout the app

// User default keys
let kUserDefaultOnboardingComplete = "com.luispadron.GradePoint.onboardingComplete"
let kUserDefaultStudentType = "com.luispadron.GradePoint.studentType"
let kUserDefaultTerms = "com.luispadron.GradePoint.terms"
let kUserDefaultTheme = "com.luispadron.GradePoint.theme"
let kUserDefaultLastDateAskedRating = "com.luispadron.GradePoint.lastDateAsked"
let kUserDefaultHasAskedRating = "com.luispadron.GradePoint.hasAskedRating"
let kUserDefaultRoundingAmount = "com.luispadron.GradePoint.roundingAmount"
let kUserDefaultGradeBirdHighScore = "com.luispadron.GradePoint.gradeBirdHighScore"

// Notifications
let kSemestersUpdatedNotification = Notification.Name("com.luispadron.GradePoint.semestersUpdated")
let kThemeUpdatedNotification = Notification.Name("com.luispadron.GradePoint.themeUpdated")

// Custom URL's
let kGradePointOpenURL = URL(string: "gradePoint://com.luispadron.gradepoint.open")!
let kEmptyWidgetActionURL = URL(string: "gradePoint://com.luispadron.gradepoint.emptyWidgetAction")!

// Misc.
let kContactEmail = "heyluispadron@gmail.com"
let kGradePointGroupId = "group.com.luispadron.GradePoint"
let kGradePointPremiumProductId = "com.luispadron.GradePoint.GradePointPremium"
