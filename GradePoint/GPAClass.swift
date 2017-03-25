//
//  GPAClass.swift
//  GradePoint
//
//  Created by Luis Padron on 3/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import RealmSwift

/// Realm object which stores class info that was entered by the user in the GPA Calculator
class GPAClass: Object {
    dynamic var associatedClassId: String?
    dynamic var name = ""
    dynamic var gradeLetter = ""
    dynamic var creditHours = 1
    let parentCalculation = LinkingObjects(fromType: GPACalculation.self, property: "gpaClasses")
    
    convenience init(name: String, gradeLetter: String, creditHours: Int) {
        self.init()
        self.name = name
        self.gradeLetter = gradeLetter
        self.creditHours = creditHours
    }
}
