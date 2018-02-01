//
//  GADInterstitial+Reload.swift
//  GradePoint
//
//  Created by Luis Padron on 2/1/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension GADInterstitial {
    static func create(unitId: String = kAdMobInterstitialId, request: GADRequest = kAdMobAdRequest,
                       delegate: GADInterstitialDelegate?) -> GADInterstitial {
        let ad = GADInterstitial(adUnitID: unitId)
        ad.delegate = delegate
        ad.load(request)
        return ad
    }

    static func reload(_ ad: GADInterstitial, withRequest request: GADRequest = kAdMobAdRequest) -> GADInterstitial {
        let newAd = GADInterstitial(adUnitID: ad.adUnitID ?? "")
        newAd.delegate = ad.delegate
        newAd.load(request)
        return newAd
    }

    static func showIfCan(_ ad: GADInterstitial, in controller: UIViewController, after: TimeInterval = 0.0) {
        guard ad.isReady && !GradePointPremium.isPurchased else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + after) {
            ad.present(fromRootViewController: controller)
        }
    }
}
