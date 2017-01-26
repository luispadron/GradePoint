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
    
    // MARK: - Properties
    
    dynamic var id = UUID().uuidString
    dynamic var name = ""
    dynamic var semester: Semester?
    var rubrics = List<Rubric>()
    var assignments = List<Assignment>()
    dynamic var colorData = Data()
    
    // MARK: - Initializers
    
    convenience init(withName name: String, inSemester semester: Semester, withRubrics rubrics:  List<Rubric>) {
        self.init()
        self.name = name
        self.semester = semester
        self.rubrics = rubrics
        self.colorData = UIColor.randomPastel.toData()
    }
    
    // MARK: - Overrides
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
}
