//
//  GPAScale.swift
//  GradePoint
//
//  Created by Luis Padron on 3/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

/// The type of the GPA Scale
@objc enum GPAScaleType: Int, RealmEnum {
    case plusScale = 1
    case nonPlusScale = -1
}

class GPAScale: Object {
    /// The shared GPAScale throughout the application
    public static var shared: GPAScale {
        guard let scale = DatabaseManager.shared.realm.object(ofType: GPAScale.self, forPrimaryKey: 1) else {
            fatalError("Unable to get application GPAScale for primary key 1")
        }
        return scale
    }

    /// The primary key for the GPAScale
    @objc dynamic var id: Int = 1
    /// Scale type
    @objc dynamic var scaleType: GPAScaleType = .plusScale 

    /// Realm array of GPA Rubrics
    var gpaRubrics = List<GPARubric>()
    
    // MARK: Public methods
    
    /// Creates a new scale with default values in Realm, returns the created scale
    /// If called when a scale has already been created, that scale will be deleted
    @discardableResult static func createScale(with scaleType: GPAScaleType) -> GPAScale {
        let realm = DatabaseManager.shared.realm
        // A scale already exists return that instead, we only want one of these scales to exist so overwrite this already
        // created scale
        if realm.objects(GPAScale.self).count > 0 {
            DatabaseManager.shared.deleteObjects(realm.objects(GPARubric.self))
            DatabaseManager.shared.deleteObjects(realm.objects(GPAScale.self))
        }
        
        // Create the object and add some rubrics
        let newScale = GPAScale()
        // The id is going to be 1 always since we only want one of these in Realm
        newScale.id = 1
        // The type of the scale
        newScale.scaleType = scaleType
        
        // The rubrics with their default values, these can be edited by the user in a settings page
        switch scaleType {
        case .plusScale:
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
        case .nonPlusScale:
            newScale.gpaRubrics.append(GPARubric(gradeLetter: "A", gradePoints: 4.0))
            newScale.gpaRubrics.append(GPARubric(gradeLetter: "B", gradePoints: 3.0))
            newScale.gpaRubrics.append(GPARubric(gradeLetter: "C", gradePoints: 2.0))
            newScale.gpaRubrics.append(GPARubric(gradeLetter: "D", gradePoints: 1.0))
            newScale.gpaRubrics.append(GPARubric(gradeLetter: "F", gradePoints: 0.0))
        }

        DatabaseManager.shared.createObject(GPAScale.self, value: newScale, update: true)

        return newScale
    }
    
    static func restoreScale() {
        // Delete the scale
        let realm = DatabaseManager.shared.realm
        DatabaseManager.shared.deleteObjects(realm.objects(GPARubric.self))
        DatabaseManager.shared.deleteObjects(realm.objects(GPAScale.self))
        
        // Create it again
        createScale(with: .plusScale)
    }
    
    /// Overwrites the scale in Realm with the new gradePoints and type provided, returns whether succesfully wrote or not
    static func overwriteScale(type: GPAScaleType, gradePoints: [Double]) {
        let realm = DatabaseManager.shared.realm
        let scale = realm.objects(GPAScale.self)[0]
        
        DatabaseManager.shared.write {
            // Delete any old rubrics
            DatabaseManager.shared.deleteObjects(scale.gpaRubrics)
            // Write new grade rubrics
            for (index, point) in gradePoints.enumerated() {
                let letter = GPAScale.gradeLetter(for: index, withScaleType: type)
                scale.gpaRubrics.append(GPARubric(gradeLetter: letter, gradePoints: point))
            }
        }
        
        DatabaseManager.shared.write {
            scale.scaleType = type
        }
    }
    
    // MARK: Helper Methods
    
    /// Helper method which returns a grade letter given the index and gpa scale type
    private static func gradeLetter(for index: Int, withScaleType type: GPAScaleType) -> String {
        switch type {
        case .plusScale:
            return kPlusScaleLetterGrades[index]
        case .nonPlusScale:
            return kLetterGrades[index]

        }
    }
    
    // MARK: - Overrides
    override class func primaryKey() -> String? {
        return "id"
    }
}
