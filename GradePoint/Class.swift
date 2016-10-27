//
//  Class.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import RealmSwift

class Class: Object {
    dynamic var name = ""
    dynamic var semester: Semester?
    var rubrics = List<Rubric>()
    
    convenience init(withName name: String, inSemester semester: Semester, withRubrics rubrics:  List<Rubric>) {
        self.init()
        self.name = name
        self.semester = semester
        self.rubrics = rubrics
    }
    
}
