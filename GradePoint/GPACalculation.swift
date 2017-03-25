//
//  GPACalculation.swift
//  GradePoint
//
//  Created by Luis Padron on 3/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// A realm object which will store calculation done in the GPA Calculator
class GPACalculation: Object {
    dynamic var id = 1 // id of 1 since there will only ever be one of these in the database
    dynamic var calculatedGpa = 0.0
    dynamic var date = Date()
    var gpaClasses = List<GPAClass>()
    
    private convenience init(calculatedGpa: Double, date: Date, associatedClasses: [GPAClass]) {
        self.init()
        self.calculatedGpa = calculatedGpa
        self.date = date
        self.gpaClasses = List(associatedClasses)
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: Helper methods
    
    @discardableResult static func createGPACalculation(withGpaClasses classes: [GPAClass], calculatedGpa: Double) -> GPACalculation {
        let realm = try! Realm()
        
        // We clear any classes from the database first since we dont need them, we only want the latest calculation and dont want to take up space
        let oldClasses = realm.objects(GPAClass.self)
        try! realm.write {
            realm.delete(oldClasses)
        }
        
        let calculation = GPACalculation(calculatedGpa: calculatedGpa, date: Date(), associatedClasses: classes)
        // Finally write the new/update GPACalculation
        if realm.objects(GPACalculation.self).count == 0 {
            try! realm.write {
                realm.create(GPACalculation.self, value: calculation, update: false)
            }
        } else {
            try! realm.write {
                // Delete the old one, doesn't need to take up space
                realm.delete(realm.objects(GPACalculation.self))
                realm.create(GPACalculation.self, value: calculation, update: false)
            }
        }
        
        return calculation
    }
}
