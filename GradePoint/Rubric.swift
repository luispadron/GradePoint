//
//  Rubric.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift

class Rubric: Object {
    
    // MARK: - Properties
    
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var name = ""
    @objc dynamic var weight: Double = 0.0
    
    // MARK: - Initializers
    
    convenience init(name: String, weight: Double) {
        self.init()
        self.name = name
        self.weight = weight
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rubric = object as? Rubric else { return false }
        return rubric == self
    }
    
    static func ==(lhs: Rubric, rhs: Rubric) -> Bool {
        return (lhs.id == rhs.id) && (lhs.name == rhs.name) && (lhs.weight == rhs.weight)
    }
}
