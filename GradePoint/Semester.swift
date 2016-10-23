//
//  Semester.swift
//  GradePoint
//
//  Created by Luis Padron on 10/23/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import Foundation

class Semester {
    var term: String!
    var year: Int!
    
    init(withTerm term: String, andYear year: Int) {
        self.term = term
        self.year = year
    }
}
