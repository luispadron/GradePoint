//
//  Grade.swift
//  GradePoint
//
//  Created by Luis Padron on 4/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

/// Data model which represents a score for a Class object
class Grade: Object {
    
    // MARK: Properties
    
    /// The id of the score in Realm
    @objc dynamic var id = UUID().uuidString
    
    /// The score
    @objc dynamic var score: Double = 0.0
    
    /// The grade letter
    @objc dynamic var gradeLetter: String = "F"
    
    // MARK: Initializers & Overrides
    
    /// Used when creating a new class which will be tracked and saved
    convenience init(score: Double) {
        self.init()
        self.score = score
        self.gradeLetter = Grade.gradeLetter(for: score)
    }
    
    /// Used when creating a Previous class
    convenience init(gradeLetter: String) {
        self.init()
        self.gradeLetter = gradeLetter
    }

    override class func primaryKey() -> String? {
        return "id"
    }
    
    // MARK: Helper Methods
    
    /// Returns a string representation of the score object, the grade letter
    /// NOTE: This function will only work properly when called on grade objects that belong to in-progress classes
    static func gradeLetter(for score: Double) -> String {
        return DatabaseManager.shared.realm.objects(GradeRubric.self).first!.letterGrade(for: score) ?? "?"
    }
}

