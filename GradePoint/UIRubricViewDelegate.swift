//
//  UIAnimatedTextFieldButtonDelegate.swift
//  UIAnimatedTextField
//
//  Created by Luis Padron on 9/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

protocol UIRubricViewDelegate: class {
    func plusButtonTouched(inCell cell: RubricTableViewCell, forState state: UIRubricViewState)
    
    func isRubricValidUpdated()
}
