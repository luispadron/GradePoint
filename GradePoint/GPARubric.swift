//
//  GPARubric.swift
//  GradePoint
//
//  Created by Luis Padron on 3/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// The GPA Rubric class, has grade letter and grade points property
class GPARubric: Object {
    dynamic var id = UUID().uuidString
    dynamic var gradeLetter: String = ""
    dynamic var gradePoints: Double = 0.0
    let associatedScale = LinkingObjects(fromType: GPAScale.self, property: "gpaRubrics")
    
    convenience init(gradeLetter: String, gradePoints: Double) {
        self.init()
        self.gradeLetter = gradeLetter
        self.gradePoints = gradePoints
    }
    
    // MARK: - Overrides
    override class func primaryKey() -> String? {
        return "id"
    }
}
