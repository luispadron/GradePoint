//
//  BasicInfoDateTapDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

/// Protocol for the semester picker
protocol SemesterPickerDelegate: class {
    /// Notifies delegate that a row was selected
    func pickerRowSelected(term: String, year: Int)
}
