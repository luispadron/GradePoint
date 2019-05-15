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
    @objc dynamic var classGradeType: ClassGradeType = .weighted
    @objc dynamic var classType: ClassType = .college
    @objc dynamic var creditHours: Double = 3.0
    @objc dynamic var semester: Semester?
    @objc dynamic var grade: Grade?
    @objc dynamic var isFavorite: Bool = false
    @objc dynamic var isDeleted: Bool = false
    @objc dynamic var colorData = Data()

    var rubrics = List<Rubric>()
    var assignments = List<Assignment>()
    
    // MARK: - Initializers
    
    /// Used to create an in-progress class
    convenience init(name: String, gradeType: ClassGradeType, classType: ClassType,
                     creditHours: Double, semester: Semester, rubrics:  [Rubric]) {
        self.init()
        self.name = name
        self.classGradeType = gradeType
        self.classType = classType
        self.creditHours = creditHours
        self.semester = semester
        self.rubrics.append(objectsIn: rubrics)
        self.colorData = UIColor.randomPastel.toData()
        self.grade = Grade(score: 0.0)
    }
    
    /// Used to create a previous class
    convenience init(name: String, classType: ClassType, creditHours: Double, semester: Semester,  grade: Grade) {
        self.init()
        self.name = name
        self.classGradeType = .previous
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
    
    // MARK: - Helper Methods
    
    /// Returns the relative score for a certain rubric
    /// Returns nil, if no assignments available for the sent in rubric.
    public func relativeScore(for rubric: Rubric) -> Double? {
        if self.classGradeType == .weighted {
            let assignments = self.assignments.filter { $0.rubric == rubric }
            if assignments.count == 0 { return nil }
            let totalScore = assignments.reduce(0) { $0 + $1.score }
            return totalScore / Double(assignments.count)
        } else {
            var score = 0.0
            var total = 0.0
            self.assignments.forEach {
                score += $0.pointsScore
                total += $0.totalPointsScore
            }
            return total == 0 ? 0 : (score / total) * 100
        }
    }

    /// Calculates the score if only have a class object
    /// SIDE EFFECT: -> Updates the Grade for the sent in class object
    public static func calculateScore(in classObj: Class) -> CGFloat {
        let rubrics = classObj.rubrics
        var assignments: [[Assignment]] = []
        // Group the assignments by their rubrics
        rubrics.forEach {
            let grouped = classObj.assignments.filter("rubric = %@", $0)
            assignments.append(Array(grouped))
        }
        
        let score = Class.calculateScore(for: assignments, in: classObj)
        
        return score
    }
    
    /// Helper method to reduce code use between the two public static methods
    /// SIDE EFFECT: -> Updates the Grade for the sent in class object
    public static func calculateScore(for groupedAssignments: [[Assignment]], in classObj: Class) -> CGFloat {
        let score: Double
        switch classObj.classGradeType {
        case .weighted: score = Class.weightedPercentage(for: groupedAssignments)
        case .points: score = Class.pointPercentage(for: Array(groupedAssignments.joined()))
        default: return CGFloat.infinity // invalid
        }

        // Also update the models Grade.score property in the DB, if its different
        if classObj.grade!.score != score {
            DatabaseManager.shared.write {
                classObj.grade?.score = score
                classObj.grade?.gradeLetter = Grade.gradeLetter(for: score)
            }
        }

        return CGFloat(score)
    }

    /// Returns the percentage score after calcuating the WEIGHTED score of a collection of assignments
    public static func weightedPercentage(for groupedAssignments: [[Assignment]]) -> Double {
        guard !groupedAssignments.isTrueEmpty else { return 0.0 }

        var weights = 0.0
        var totalScore = 0.0

        for assignments in groupedAssignments {
            if assignments.count == 0 { continue }
            weights += assignments[0].rubric!.weight

            var sumTotal = 0.0
            for assignment in assignments { sumTotal += assignment.score }

            sumTotal /= Double(assignments.count)
            totalScore += assignments[0].rubric!.weight * sumTotal
        }
        
        return Double(totalScore / weights)
    }


    /// Returns the percentage score after calcuating the POINT score of a collection of assignments
    public static func pointPercentage(for assignments: [Assignment]) -> Double {
        var score = 0.0
        var totalScore = 0.0
        assignments.forEach {
            score += $0.pointsScore
            totalScore += $0.totalPointsScore
        }

        return totalScore == 0 ? 0 : (score / totalScore) * 100
    }
    
    
    // MARK: - Computed Properties
    
    /// Returns the color after getting it from the color data
    var color: UIColor { return NSKeyedUnarchiver.unarchiveObject(with: self.colorData) as! UIColor }

    /// Returns whether or not a class is in progress
    var isInProgress: Bool { return self.classGradeType != .previous }
}
