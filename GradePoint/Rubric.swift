//
//  Rubric.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift

class Rubric: Object {
    dynamic var name = ""
    dynamic var weight: Double = 0.0
    
    convenience init(withName name: String, andWeight weight: Double) {
        self.init()
        self.name = name
        self.weight = weight
    }
}
