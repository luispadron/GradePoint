//
//  ClassType.swift
//  GradePoint
//
//  Created by Luis Padron on 4/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation

/// The type of the GPA Scale
@objc enum ClassType: Int {
    // College students only have college option, highschool students have all options
    case regular = 1
    case honors = 2
    case ap = 3
    case ib = 4
    case college = 5
    
    func name() -> String {
        switch self {
        case .regular:
            return "Regular"
        case .honors:
            return "Honors"
        case .ap:
            return "AP"
        case .ib:
            return "IB"
        case .college:
            return "College"
        }
    }
}
