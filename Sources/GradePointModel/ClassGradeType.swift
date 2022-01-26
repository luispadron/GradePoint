//
//  ClassGradeType.swift
//  GradePoint
//
//  Created by Luis Padron on 2/26/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import Foundation
import RealmSwift

@objc enum ClassGradeType: Int, RealmEnum {
    case weighted = 0
    case points = 1
    case previous = 2
}
