//
//  AddEditAssignmentViewDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 1/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

/// Protocol for the AddEditAssignmentTableViewController
protocol AddEditAssignmentViewDelegate: class {
    /// Notifies the delegate that an assignment has be updated
    func didFinishUpdating(assignment: Assignment)
    /// Notifies the delegate that an assignment was created
    func didFinishCreating(assignment: Assignment)
}
