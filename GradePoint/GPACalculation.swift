//
//  GPACalculation.swift
//  GradePoint
//
//  Created by Luis Padron on 3/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

/// A realm object which will store calculation done in the GPA Calculator
class GPACalculation: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var calculatedGpa = 0.0
    @objc dynamic var date = Date()
    @objc dynamic var isWeighted = true
    
    convenience init(calculatedGpa: Double, date: Date, weighted: Bool) {
        self.init()
        self.calculatedGpa = calculatedGpa
        self.date = date
        self.isWeighted = weighted
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
