//
//  Class.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import Foundation

class Class {
    var name: String!
    var semester: Semester!
    lazy var rubrics = [Rubric]()
    
    init(withName name: String, inSemester semester: Semester, withRubrics rubrics:  [Rubric]) {
        self.name = name
        self.semester = semester
        self.rubrics = rubrics
    }
    
}
