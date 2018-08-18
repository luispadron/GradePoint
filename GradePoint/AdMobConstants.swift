//
//  AdMobConstants.swift
//  GradePoint
//
//  Created by Luis Padron on 8/17/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import Foundation
import GoogleMobileAds

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

