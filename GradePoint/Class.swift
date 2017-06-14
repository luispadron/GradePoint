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
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var classType: ClassType = .college
    @objc dynamic var creditHours = 3
    @objc dynamic var semester: Semester?
    @objc dynamic var grade: Grade?
    var rubrics = List<Rubric>()
    var assignments = List<Assignment>()
    @objc dynamic var colorData = Data()
    
    // MARK: - Initializers
    
    /// Used to create an in-progress class
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
    
    /// Used to create a previous class
    convenience init(name: String, classType: ClassType, creditHours: Int, semester: Semester,  grade: Grade) {
        self.init()
        self.name = name
        self.classType = classType
        self.creditHours = creditHours
        self.semester = semester
        self.grade = grade
        self.colorData = UIColor.randomPastel.toData()
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["color"]
    }
    
    // MARK: Helper Methods
    
    /// Returns the calculated score based on assignments, also mutates the Grade objects score property if detects a change
    func calculateScore() -> Double {
        if self.assignments.count == 0 { return 0.00 }
        
        let assignmentsSectionedByRubric = self.rubrics.map { self.assignments.filter("associatedRubric = %@", $0) }
        
        var weights = 0.0
        var totalScore = 0.0
        
        for assignments in assignmentsSectionedByRubric {
            if assignments.count == 0 { continue }
            weights += assignments[0].associatedRubric!.weight
            
            var sumTotal = 0.0
            for assignment in assignments { sumTotal += assignment.score }
            
            sumTotal /= Double(assignments.count)
            totalScore += assignments[0].associatedRubric!.weight * sumTotal
        }
        
        let score = Double(totalScore / weights).roundedUpTo(2)
        // Also update the models Grade.score property in the DB, if its different
        if self.grade!.score != score {
            try! Realm().write {
                self.grade?.score = score
                self.grade?.gradeLetter = Grade.gradeLetter(forScore: score)
            }
        }
        return score
    }
    
    // MARK: - Computed Properties
    
    /// Returns the color after getting it from the color data
    var color: UIColor { get { return NSKeyedUnarchiver.unarchiveObject(with: self.colorData) as! UIColor } }
    
    /// Returns whether or not the class is inprogress or not
    /// Does so by checking whether or not at least 1 rubric has been added, if this is false then
    /// it must be a Previous Class due to the fact previous classes cannot have rubrics
    var isClassInProgress: Bool { get { return self.rubrics.count > 0 } }
    
}
