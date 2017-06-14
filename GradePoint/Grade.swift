//
//  Grade.swift
//  GradePoint
//
//  Created by Luis Padron on 4/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

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
        self.gradeLetter = Grade.gradeLetter(forScore: score)
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
    static func gradeLetter(forScore score: Double) -> String {
        let scale = try! Realm().objects(GPAScale.self).first!
        switch scale.scaleType {
        case .plusScale:
            switch score {
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
            switch score {
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

