//
//  InterstitialAdController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/1/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit
import GoogleMobileAds

/**
 This class is meant to control a GADInterstitial,
 it will determine whether or not to present the ad and when to present it.
 */
class InterstitialAdController: NSObject {
    /// The unit id for the ad view
    public static let adUnitId: String = kAdMobInterstitialId

    /// The Google Ad request object for the ad view
    public static let adRequest: GADRequest = kAdMobAdRequest

    /// Singelton of the ad controller
    public static let shared: InterstitialAdController = InterstitialAdController()

    /// The ad view this controller, controls
    private var adView: GADInterstitial

    /// Time since last ad was displayed
    private var timeSinceLastAd: Date?

    override init() {
        self.adView = GADInterstitial(adUnitID: InterstitialAdController.adUnitId)
        super.init()
        self.adView.delegate = self
    }

    /// Reloads the interstitial ad
    private func reloadAdView() {
        self.adView = GADInterstitial(adUnitID: InterstitialAdController.adUnitId)
        self.adView.delegate = self
        self.adView.load(InterstitialAdController.adRequest)
    }

    /// Prepares ad controller to display ads, should be called before presenting an ad
    public func prepare() {
        self.adView.load(InterstitialAdController.adRequest)
    }

    /// Shows an ad if possible
    public func showAdIfCan(in controller: UIViewController) {
        guard !GradePointPremium.isPurchased else { return }
        if self.adView.hasBeenUsed { self.reloadAdView() }
        guard self.adView.isReady else { return }

        // Only show ads every 5 minutes
        if let lastTime = self.timeSinceLastAd {
            guard Date().timeIntervalSince(lastTime) > 300 else { return }
            self.adView.present(fromRootViewController: controller)
        } else {
            self.adView.present(fromRootViewController: controller)
        }
    }
}

// MARK: Google AdMob delegate

extension InterstitialAdController: GADInterstitialDelegate {
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        self.timeSinceLastAd = Date()
    }

    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        self.reloadAdView()
    }
}
