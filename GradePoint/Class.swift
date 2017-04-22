//
//  Class.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift
import UIKit

/// The type of the GPA Scale
@objc enum ClassType: Int {
    // College students only have college option, highschool students have all options
    case college = 1
    case regular = 2
    case honors = 3
    case ap = 4
    case ib = 5
}

class Class: Object {
    
    // MARK: - Properties
    
    dynamic var id = UUID().uuidString
    dynamic var name = ""
    dynamic var creditHours = 3
    dynamic var semester: Semester?
    var rubrics = List<Rubric>()
    var assignments = List<Assignment>()
    dynamic var colorData = Data()
    dynamic var classType: ClassType = .college
    
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
    var score: Double {
        get {
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
            
            return Double(totalScore / weights).roundedUpTo(2)
        }
    }
    
    /// Returns the letter grade based on the score and the GPA Scale the user has set
    var letterGrade: String {
        get {
            let scale = try! Realm().objects(GPAScale.self)[0]
            switch scale.scaleType {
            case .plusScale:
                switch self.score {
                case 0.00...59.99:
                    return "F"
                case 60.00...62.99:
                    return "D-"
                case 63.00...66.99:
                    return "D"
                case 67.00...69.99:
                    return "D+"
                case 70.00...72.99:
                    return "C-"
                case 73.00...76.99:
                    return "C"
                case 77.00...79.99:
                    return "C+"
                case 80.00...82.99:
                    return "B-"
                case 83.00...86.99:
                    return "B"
                case 87.00...89.99:
                    return "B+"
                case 90.00...92.99:
                    return "A-"
                case 93.00...99.99:
                    return "A"
                default:
                    return "A+"
                }
            case .nonPlusScale:
                switch self.score {
                case 0.00...59.99:
                    return "F"
                case 60.00...69.99:
                    return "D"
                case 70.00...79.99:
                    return "C"
                case 80.00...89.99:
                    return "B"
                default:
                    return "A"
                }
            }
        }
    }
}
