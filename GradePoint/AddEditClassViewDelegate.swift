//
//  AddEditClassViewDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 2/6/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

/// Protocol for the AddEditClassTableViewController
protocol AddEditClassViewDelegate: class {
    /// Notifies delegate that the class was updated
    func didFinishUpdating(classObj: Class)
    /// Notifies delegate that a new class was created
    func didFinishCreating(newClass classObj: Class)
}
