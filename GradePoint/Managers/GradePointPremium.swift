//
//  GradePointPremium.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

public struct GradePointPremium {
    public static let productIds: Set<ProductIdentifier> = [gradePointPremiumProductId]

    public static let store: IAPManager = IAPManager(productIds: productIds)

    public typealias PurchaseCompletionHandler = (Bool) -> Void

    public static func purchase(completion: @escaping PurchaseCompletionHandler) {
        store.requestProducts { success, products in
            if let product = products?.first, success {
                store.buyProduct(product)
            } else {
                completion(false)
            }
        }
    }
}
