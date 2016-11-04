//
//  IntExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 11/3/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import Darwin

extension Int {
    public static func random(withLowerBound lower: Int = min, andUpperBound upper: Int = max) -> Int {
        return Int(arc4random_uniform(UInt32(upper)) + UInt32(lower))
    }
}
