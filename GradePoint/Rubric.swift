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
    let parentClass = LinkingObjects(fromType: Class.self, property: "rubrics")
    
    // MARK: - Initializers
    
    convenience init(withName name: String, andWeight weight: Double) {
        self.init()
        self.name = name
        self.weight = weight
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
