//
//  Class.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift
import UIKit

class Class: Object {
    
    // MARK: - Properties
    
    dynamic var id = UUID().uuidString
    dynamic var name = ""
    dynamic var classType: ClassType = .college
    dynamic var creditHours = 3
    dynamic var semester: Semester?
    dynamic var grade: Grade?
    var rubrics = List<Rubric>()
    var assignments = List<Assignment>()
    dynamic var colorData = Data()
    
    // MARK: - Initializers
    
    convenience init(name: String, classType: ClassType, creditHours: Int, semester: Semester, rubrics:  List<Rubric>) {
        self.init()
        self.name = name
        self.classType = classType
        self.creditHours = creditHours
        self.semester = semester
        self.rubrics = rubrics
        self.colorData = UIColor.randomPastel.toData()
        self.grade = Grade(score: 0.0)
    }
    
    convenience init(name: String, classType: ClassType, creditHours: Int, semester: Semester,  grade: Grade, rubrics:  List<Rubric>) {
        self.init()
        self.name = name
        self.classType = classType
        self.creditHours = creditHours
        self.semester = semester
        self.rubrics = rubrics
        self.colorData = UIColor.randomPastel.toData()
        self.grade = grade
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["color"]
    }
    
    // MARK: Helper Methods
    
    /// Returns the calculated score based on assignments, also mutates the Grade objects score property
    
    
    // MARK: - Computed Properties
    
    /// Returns the color after getting it from the color data
    var color: UIColor { get { return NSKeyedUnarchiver.unarchiveObject(with: self.colorData) as! UIColor } }
    
}
