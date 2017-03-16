//
//  UIAddGPAViewDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 3/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

protocol UIAddGPAViewDelegate: class {
    /// Notifies when the add button for the view has been touched
    func addButtonTouched(forView view: UIAddGPAView)
}
