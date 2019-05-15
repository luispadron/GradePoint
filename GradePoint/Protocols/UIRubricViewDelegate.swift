//
//  UIAnimatedTextFieldButtonDelegate.swift
//  UIAnimatedTextField
//
//  Created by Luis Padron on 9/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

/// Protocol for the rubric view
protocol UIRubricViewDelegate: class {
    /// Notifies delegate that the plus button was touched
    func plusButtonTouched(_ view: UIRubricView, withState state: UIRubricViewState?)
    /// Notifies delgate that the rubrics valid state was updated
    func isRubricValidUpdated(forView view: UIRubricView)
    /// Notifies when the weight fields keyboard 'Calculate' button was tapped
    func calculateButtonWasTapped(forView view: UIRubricView, textField: UITextField)
}
