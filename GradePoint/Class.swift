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
    dynamic var creditHours = 3
    dynamic var semester: Semester?
    var rubrics = List<Rubric>()
    var assignments = List<Assignment>()
    dynamic var colorData = Data()
    
    // MARK: - Initializers
    
    convenience init(withName name: String, creditHours: Int, inSemester semester: Semester, withRubrics rubrics:  List<Rubric>) {
        self.init()
        self.name = name
        self.creditHours = creditHours
        self.semester = semester
        self.rubrics = rubrics
        self.colorData = UIColor.randomPastel.toData()
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    
    // MARK: - Helper Properties
    
    /// Returns the color after getting it from the color data
    var color: UIColor { get { return NSKeyedUnarchiver.unarchiveObject(with: self.colorData) as! UIColor } }
    
    /// Returns the score after calculating all the assignments and rubrics
    var score: CGFloat {
        get {
            let assignmentsSectionedByRubric = self.rubrics.map { self.assignments.filter("associatedRubric = %@", $0) }
            let count = assignmentsSectionedByRubric.filter { $0.count > 0 }.count
            guard count > 0 else { return 0.0 }
            
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
            
            return CGFloat(totalScore / weights)
        }
    }
}
