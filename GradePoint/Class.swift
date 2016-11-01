//
//  Class.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift
import UIKit

class Class: Object {
    dynamic var name = ""
    dynamic var semester: Semester?
    var rubrics = List<Rubric>()
    dynamic var colorData = Data()
    
    // This is here as well as in Semester, to allow for sorting based on year
    // Sadly Realm does not yet support sorting via child properties
    dynamic var year = 0
    
    convenience init(withName name: String, inSemester semester: Semester, withRubrics rubrics:  List<Rubric>) {
        self.init()
        self.name = name
        self.semester = semester
        self.rubrics = rubrics
        self.colorData = UIColor.randomPastel.toData()
        
        self.year = semester.year
    }
    
}
