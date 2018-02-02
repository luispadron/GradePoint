//
//  InterstitialAdController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/1/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit
import Foundation
import GoogleMobileAds
import LPSnackbar

/**
 This class is meant to control a GADInterstitial,
 it will determine whether or not to present the ad and when to present it.
 */
class InterstitialAdController: NSObject {
    /// The date since we last told the user to purchase premimum
    private static let userDefaultsKey: String = "com.luispadron.GradePoint.dateSinceLastPromotedPremium"

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

    /// The saved view controller, saved when `showAdIfCan` is called. This controller reference is used to
    /// present premium promotions if possible.
    private weak var viewController: UIViewController?

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

    /// Promote GradePoint premium
    private func promotePremium() {
        if let lastDate = UserDefaults.standard.value(forKey: InterstitialAdController.userDefaultsKey) as? Date {
            let prev = Calendar.current.startOfDay(for: lastDate)
            let now = Calendar.current.startOfDay(for: Date())
            guard let days = Calendar.current.dateComponents([.day], from: prev, to: now).day, days > 5 else { return }
            self.presentPromotion()
        } else {
            UserDefaults.standard.set(Date(), forKey: InterstitialAdController.userDefaultsKey)
            self.presentPromotion()
        }
    }

    /// Presents GradePoint premium promotion
    private func presentPromotion() {
        let snack = LPSnackbar(title: "Remove Ads and more with premium", buttonTitle: "Buy")
        snack.bottomSpacing = 30
        snack.show(displayDuration: 5.0, animated: true) { [weak self] (actioned) in
            if actioned {
                guard let controller = self?.viewController else { return }
                GradePointPremium.displayPremiumOnboarding(in: controller)
            }
        }
        UserDefaults.standard.set(Date(), forKey: InterstitialAdController.userDefaultsKey)
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

        self.viewController = controller

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
        self.promotePremium()
    }
}
