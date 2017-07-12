//
//  LPSnackbar.swift
//  GradePoint
//
//  Created by Luis Padron on 7/11/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class LPSnackbar {
    
    // MARK: Properties
    
    open lazy var view: LPSnackbarView = {
        let snackView = LPSnackbarView(frame: .zero)
        snackView.controller = self
        return snackView
    }()
    
    open var height: CGFloat = 40.0 {
        didSet {
            // Update height
            let oldFrame = self.view.frame
            self.view.frame = CGRect(x: oldFrame.origin.x, y: oldFrame.origin.y,
                                     width: oldFrame.width, height: self.height)
            self.view.setNeedsLayout()
        }
    }
    
    open var bottomSpacing: CGFloat = 12.0 {
        didSet {
            // Update frame
            let clearedY = view.frame.origin.y + oldValue
            let newY = clearedY - self.bottomSpacing
            let oldFrame = self.view.frame
            self.view.frame = CGRect(x: oldFrame.origin.x, y: newY,
                                     width: oldFrame.width, height: oldFrame.height)
            self.view.setNeedsLayout()
        }
    }

    // MARK: Initializers
    
    public init (title: String, buttonTitle: String) {
        view.titleLabel.text = title
        view.button.setTitle(buttonTitle, for: .normal)
    }
    
    public init(attributedTitle: NSAttributedString, attributedButtonTitle: NSAttributedString) {
        view.titleLabel.attributedText = attributedTitle
        view.button.setAttributedTitle(attributedButtonTitle, for: .normal)
    }
    
    
    // MARK: Private methods
    
    internal func frameForView() -> CGRect {
        guard let window = UIApplication.shared.keyWindow else {
            return .zero
        }
        
        // Set frame for view
        let width: CGFloat = window.bounds.width * 0.98
        let startX: CGFloat = (window.bounds.width - width) / 2.0
        let startY: CGFloat = window.bounds.maxY - height - bottomSpacing
        return CGRect(x: startX, y: startY, width: width, height: height)
    }
    
    // MARK: Public methods
    
    open func show() {
        guard let window = UIApplication.shared.keyWindow else {
            print("Unable to get window, thus cannot show LPSnackBar")
            return
        }
        
        view.setNeedsLayout()
        window.addSubview(view)
    }
    
    // MARK: Deinit
    
    
}
