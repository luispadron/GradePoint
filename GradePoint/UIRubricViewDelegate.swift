//
//  UIAnimatedTextFieldButtonDelegate.swift
//  UIAnimatedTextField
//
//  Created by Luis Padron on 9/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

/// Protocol for the rubric view
protocol UIRubricViewDelegate: class {
    /// Notifies delegate that the plus button was touched
    func plusButtonTouched(inCell cell: RubricTableViewCell, withState state: UIRubricViewState?)
    /// Notifies delgate that the rubrics valid state was updated
    func isRubricValidUpdated(forView view: UIRubricView)
    
}
