//
//  Semester.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

class Semester: Object {
    
    // MARK: - Properties
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var term = ""
    @objc dynamic var year = 0
    
    // MARK: - Initializers
    
    convenience init(term: String, year: Int) {
        self.init()
        self.term = term
        self.year = year
    }
    
    // MARK: - Overrides

    override func isEqual(_ object: Any?) -> Bool {
        guard let sem = object as? Semester else { return false }
        return sem.term == self.term && sem.year == self.year
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["terms"]
    }
    
    override func copy() -> Any {
        let copy = Semester(term: term, year: year)
        copy.id = id
        return copy
    }
    
    // MARK: Helpers
    
    public static var possibleTerms: [String] {
        return UserDefaults.standard.stringArray(forKey: userDefaultTerms) ?? []
    }
    
    public static var possibleYears: [Int] {
        var years = [Int]()
        let date = Date()
        let calendar = NSCalendar.current
        let currentYear = calendar.component(.year, from: date)
        
        // For the current year, go one ahead and 10 behind.
        for i in 0...10 {
            years.append(currentYear - i)
        }
        // Finally one ahead
        years.insert(currentYear + 1, at: 0)
        return years
    }
}
