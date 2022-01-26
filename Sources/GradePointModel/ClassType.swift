//
//  ClassType.swift
//  GradePoint
//
//  Created by Luis Padron on 4/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

/// The type of the GPA Scale
@objc enum ClassType: Int, RealmEnum {
    // College students only have college option, high school students have all options
    case regular = 1
    case honors = 2
    case ap = 3
    case ib = 4
    case college = 5
    
    /// Convenience function which returns a name to associate with a case in the enum
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
    
    /// Returns the amount of additional grade points awarded, for specific class type
    func additionalGradePoints() -> Double {
        switch self {
        case .regular:
            return 0.0
        case .honors:
            return 0.5
        case .ap:
            return 1.0
        case .ib:
            return 1.0
        case .college:
            return 1.0
        }
    }
}
