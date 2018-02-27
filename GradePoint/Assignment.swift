//
//  Assignment.swift
//  GradePoint
//
//  Created by Luis Padron on 12/5/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

class Assignment: Object {
    
    // MARK: - Properties
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var date = Date()
    @objc dynamic var score: Double = 0.0
    @objc dynamic var rubric: Rubric?
    // Score of points when using point based class system
    @objc dynamic var pointsScore: Double = 0.0
    @objc dynamic var totalPointsScore: Double = 0.0

    let parentClass = LinkingObjects(fromType: Class.self, property: "assignments")
    
    // MARK: - Initializers

    /// Creates a new Assignment for a weighted class
    convenience init(name: String, date: Date, score: Double, associatedRubric: Rubric) {
        self.init()
        self.name = name
        self.date = date
        self.score = score
        self.rubric = associatedRubric
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }

    /// Returns the percentage of the assignment, takes into account the type of assignment (weighted/point)
    public var percentage: Double {
        if totalPointsScore == 0 {
            return score
        } else {
            return (pointsScore / totalPointsScore) * 100
        }
    }
}
