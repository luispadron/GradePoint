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
let userDefaultOnboardingComplete = "com.luispadron.GradePoint.onboardingComplete"
let userDefaultStudentType = "com.luispadron.GradePoint.studentType"
let userDefaultGradingType = "com.luispadron.GradePoint.gradingType"
let userDefaultTerms = "com.luispadron.GradePoint.terms"
let userDefaultTheme = "com.luispadron.GradePoint.theme"

// Notifications
let semestersUpdatedNotification = Notification.Name("com.luispadron.GradePoint.semestersUpdated")
let themeUpdatedNotification = Notification.Name("com.luispadron.GradePoint.themeUpdated")

// Custom URL's
let openUrl = URL(string: "gradePoint://com.luispadron.gradepoint.open")!
let emptyWidgetActionUrl = URL(string: "gradePoint://com.luispadron.gradepoint.emptyWidgetAction")!

// Misc.
let contactEmail = "heyluispadron@gmail.com"
let groupId = "group.com.luispadron.GradePoint"
