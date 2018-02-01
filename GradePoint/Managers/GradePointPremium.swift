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

    public static func displayPremiumOnboarding(in controller: UIViewController) {
        let storyboard = UIStoryboard(name: "GradePointPremium", bundle: nil)
        let onboardingController = storyboard.instantiateViewController(withIdentifier: "GPPPageViewController")
        controller.present(onboardingController, animated: true, completion: nil)
    }
}
