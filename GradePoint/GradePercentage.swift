//
//  GradePercentage.swift
//  GradePoint
//
//  Created by Luis Padron on 5/14/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

class GradePercentage: Object {
    public enum PercentageType {
        case lowerBound
        case upperBound
    }
    
    // MARK: Properties
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var lowerBound: Double = 0.0
    @objc dynamic var upperBound: Double = Double.infinity

    // MARK: Realm

    convenience init(lower: Double, upper: Double) {
        self.init()
        self.lowerBound = lower
        self.upperBound = upper
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    // MARK: API

    public func isInRange(_ val: Double) -> Bool {
        let range = lowerBound...upperBound
        return range.contains(val)
    }
}
