//
//  GPAScale.swift
//  GradePoint
//
//  Created by Luis Padron on 3/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

class GPAScale: Object {
    /// The primary key for the GPAScale
    dynamic var id: Int = 1
    /// Realm array of GPA Rubrics
    var gpaRubrics = List<GPARubric>()
    
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
    
    // MARK: - Overrides
    override class func primaryKey() -> String? {
        return "id"
    }
}
