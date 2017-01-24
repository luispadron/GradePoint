//
//  Assignment.swift
//  GradePoint
//
//  Created by Luis Padron on 12/5/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift

class Assignment: Object {
    
    // MARK: - Properties
    
    dynamic var id = UUID().uuidString
    dynamic var name = ""
    dynamic var date = Date()
    dynamic var score: Double = 0.0
    dynamic var associatedRubric: Rubric?
    
    // MARK: - Initializers
    
    convenience init(name: String, date: Date, score: Double, associatedRubric: Rubric) {
        self.init()
        
        // Assign values
        self.name = name
        self.date = date
        self.score = score
        self.associatedRubric = associatedRubric
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
