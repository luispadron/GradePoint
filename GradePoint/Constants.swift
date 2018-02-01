//
//  Constants.swift
//  GradePoint
//
//  Created by Luis Padron on 7/22/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds

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

// AdMob
var kAdMobAppId: String {
    if let adMobFile = Bundle.main.url(forResource: "AdMob", withExtension: "plist"),
        let adMobDict = NSDictionary(contentsOf: adMobFile) as? [String: String],
        let appId = adMobDict["AdMobAppId"] {
        return appId
    } else {
        fatalError("Unable to load AdMob App Id. Make sure AdMob.plist is in Xcode.")
    }
}
var kAdMobBannerId: String {
    if let adMobFile = Bundle.main.url(forResource: "AdMob", withExtension: "plist"),
        let adMobDict = NSDictionary(contentsOf: adMobFile) as? [String: String],
        let unitId = adMobDict["AdMobBannerUnitId"] {
        return unitId
    } else {
        fatalError("Unable to load AdMob banner id. Make sure AdMob.plist is in Xcode.")
    }
}

var kAdMobInterstitialId: String {
    if let adMobFile = Bundle.main.url(forResource: "AdMob", withExtension: "plist"),
        let adMobDict = NSDictionary(contentsOf: adMobFile) as? [String: String],
        let unitId = adMobDict["AdMobInterstitialUnitId"] {
        return unitId
    } else {
        fatalError("Unable to load AdMob interstitial id. Make sure AdMob.plist is in Xcode.")
    }
}

var kAdMobAdRequest: GADRequest {
    let request = GADRequest()
    request.testDevices = [kGADSimulatorID]
    return request
}

let kAdMobBannerTestId = "ca-app-pub-3940256099942544/2934735716"
let kAdMobInterstitalTestId = "ca-app-pub-3940256099942544/4411468910"

// Misc.
let kContactEmail = "heyluispadron@gmail.com"
let kGradePointGroupId = "group.com.luispadron.GradePoint"
let kGradePointPremiumProductId = "com.luispadron.GradePoint.GradePointPremium"

