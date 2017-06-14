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
    @objc dynamic var id = UUID().uuidString
    /// The letter grade, such as "A+"
    @objc dynamic var gradeLetter: String = ""
    /// The amount of grade points for this grade, such as 4.0
    @objc dynamic var gradePoints: Double = 0.0
    /// The scale associated with this rubric in realm
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
