//
//  Double+Round.swift
//  GradePoint
//
//  Created by Luis Padron on 2/18/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Darwin

extension Double {
    /// Rounds up to a specified number of decimal places
    func roundedUpTo(_ decimalPlaces: Int) -> Double {
        let places = Double(10 * decimalPlaces)
        return Double(Darwin.round(places * self) / places)
    }
}
