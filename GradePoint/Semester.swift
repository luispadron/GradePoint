//
//  Semester.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift

class Semester: Object {
    
    // MARK: - Properties
    
    dynamic var id = UUID().uuidString
    static let terms = ["Spring", "Summer", "Fall", "Winter"]
    dynamic var term = ""
    dynamic var year = 0
    
    // MARK: - Initializers
    
    convenience init(withTerm term: String, andYear year: Int) {
        self.init()
        self.term = term
        self.year = year
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["terms"]
    }
}
