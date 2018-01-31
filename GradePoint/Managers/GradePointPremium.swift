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
}
