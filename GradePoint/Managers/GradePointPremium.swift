//
//  GradePointPremium.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

public struct GradePointPremium {
    public static let productIds: Set<ProductIdentifier> = [kGradePointPremiumProductId]

    public static let store: IAPManager = IAPManager(productIds: productIds)

    public typealias PurchaseCompletionHandler = (Bool) -> Void

    public static func purchase(completion: @escaping PurchaseCompletionHandler) {
        store.requestProducts { success, products in
            if let product = products?.first, success {
                store.buyProduct(product) { success in
                    completion(success)
                }
            } else {
                completion(false)
            }
        }
    }

    public static var isPurchased: Bool {
        return UserDefaults.standard.bool(forKey: kGradePointPremiumProductId)
    }

    public static func displayPremiumOnboarding(in controller: UIViewController? = nil) {
        let storyboard = UIStoryboard(name: "GradePointPremium", bundle: nil)
        let onboardingController = storyboard.instantiateViewController(withIdentifier: "GPPPageViewController")

        if let controller = controller {
            controller.present(onboardingController, animated: true, completion: nil)
        } else {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            onboardingController.modalPresentationStyle = .overCurrentContext
            appDelegate?.window?.rootViewController?.present(onboardingController, animated: true, completion: nil)
        }
    }

    // MARK: Promotional alerts

    public static func presentPromotionalAlertIfNeeded(in viewController: UIViewController) {
        let key = "com.luispadron.GradePoint.GradePointPremium.Promotion1"
        let hasPresented = UserDefaults.standard.bool(forKey: key)
        guard !hasPresented, !isPurchased else { return }

        UserDefaults.standard.set(true, forKey: key)

        GradePointPremium.store.requestProducts { (success, products) in
            guard let price = products?.first?.localizedPrice, success else { return }
            let title = "GradePoint Premium Sale"
            let message = "Get premium for \(price)! Help support the continued development of GradePoint and get some goodies as well."
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let storyboard = UIStoryboard(name: "GradePointPremium", bundle: nil)
            let onboardingController = storyboard.instantiateViewController(withIdentifier: "GPPPageViewController")

            let buyAction = UIAlertAction(title: "Get Premium", style: .default, handler: { _ in
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                onboardingController.modalPresentationStyle = .overCurrentContext
                DispatchQueue.main.async {
                    appDelegate?.window?.rootViewController?.present(onboardingController, animated: true, completion: nil)
                }
            })
            let closeAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)

            controller.addAction(closeAction)
            controller.addAction(buyAction)
            DispatchQueue.main.async {
                viewController.present(controller, animated: true, completion: nil)
            }
        }
    }
}
