//
//  GPAScale.swift
//  GradePoint
//
//  Created by Luis Padron on 3/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// The type of the GPA Scale
@objc enum GPAScaleType: Int {
    case plusScale = 1
    case nonPlusScale = -1
}

class GPAScale: Object {
    /// The primary key for the GPAScale
    dynamic var id: Int = 1
    /// Scale type
    dynamic var scaleType: GPAScaleType = .plusScale
    /// Realm array of GPA Rubrics
    var gpaRubrics = List<GPARubric>()
    
    // MARK: Public methods
    
    /// Creates a new scale with default values in Realm, returns the created scale
    @discardableResult static func createInitialScale() -> GPAScale {
        let realm = try! Realm()
        // A scale already exists return that instead, we only want one of these scales to exist in Realm
        if realm.objects(GPAScale.self).count > 0 { return realm.objects(GPAScale.self)[0] }
        
        // Create the object and add some rubrics
        let newScale = GPAScale()
        // The id is going to be 1 always since we only want one of these in Realm
        newScale.id = 1
        // The rubrics with their default values, these can be edited by the user in a settings page
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "A+", gradePoints: 4.0))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "A", gradePoints: 4.0))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "A-", gradePoints: 3.67))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "B+", gradePoints: 3.3))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "B", gradePoints: 3.0))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "B-", gradePoints: 2.67))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "C+", gradePoints: 2.30))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "C", gradePoints: 2.0))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "C-", gradePoints: 1.67))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "D+", gradePoints: 1.30))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "D", gradePoints: 1.0))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "D-", gradePoints: 0.67))
        newScale.gpaRubrics.append(GPARubric(gradeLetter: "F", gradePoints: 0.0))

        try! realm.write {
            realm.create(GPAScale.self, value: newScale, update: true)
        }
        
        return newScale
    }
    
    static func restoreScale() {
        // Delete the scale
        let realm = try! Realm()
        try! realm.write {
            realm.delete(realm.objects(GPAScale.self))
        }
        // Create it again
        createInitialScale()
    }
    
    /// Overwrites the scale in Realm with the new gradePoints and type provided, returns whether succesfully wrote or not
    static func overwriteScale(type: GPAScaleType, gradePoints: [Double]) -> Bool {
        let realm = try! Realm()
        let scale = realm.objects(GPAScale.self)[0]
        var didWrite = true
        
        try! realm.write {
            // Delete any old rubrics
            realm.delete(scale.gpaRubrics)
            // Write new grade rubrics, this may fail if for some reason we cant find a grade letter, thus it will break and return false
            for (index, point) in gradePoints.enumerated() {
                if let gradeLetter = gradeLetter(forIndex: index, withScaleType: type) {
                    scale.gpaRubrics.append(GPARubric(gradeLetter: gradeLetter, gradePoints: point))
                } else {
                    didWrite = false
                    break
                }
            }
        }
        
        // Finally if we did write the above, change the scale to whatever we updated it to
        if didWrite { try! realm.write { scale.scaleType = type } }
        
        return didWrite
        
    }
    
    // MARK: Helper Methods
    
    /// Helper method which returns a grade letter given the index and gpa scale type
    private static func gradeLetter(forIndex index: Int, withScaleType type: GPAScaleType) -> String? {
        switch type {
        case .plusScale:
            switch index {
            case 0:
                return "A+"
            case 1:
                return "A"
            case 2:
                return "A-"
            case 3:
                return "B+"
            case 4:
                return "B"
            case 5:
                return "B-"
            case 6:
                return "C+"
            case 7:
                return "C"
            case 8:
                return "C-"
            case 9:
                return "D+"
            case 10:
                return "D"
            case 11:
                return "D-"
            case 12:
                return "F"
            default:
                return nil
            }
        case .nonPlusScale:
            switch index {
            case 0:
                return "A"
            case 1:
                return "B"
            case 2:
                return "C"
            case 3:
                return "D"
            case 4:
                return "F"
            default:
                return nil
            }
        }
    }
    
    // MARK: - Overrides
    override class func primaryKey() -> String? {
        return "id"
    }
}
