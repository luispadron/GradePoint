//
//  LPSnackbarView.swift
//  GradePoint
//
//  Created by Luis Padron on 7/11/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class LPSnackbarView: UIView {
    
    // MARK: Properties
    
    internal var controller: LPSnackbar?
    
    open var leftPadding: CGFloat = 8.0 {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    open var rightPadding: CGFloat = 8.0 {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: Overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    // MARK: Private methods
    
    private func initialize() {
        // Customize UI
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundColor = UIColor(red: 0.180, green: 0.180, blue: 0.180, alpha: 1.00)
        layer.opacity = 0.98
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.4
        layer.cornerRadius = 4.0
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(button)
        
        //// Add constraints
        // Pin title label to left
        NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal,
                           toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: leftPadding).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal,
                           toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        // Pin button to right
        NSLayoutConstraint(item: button, attribute: .trailing, relatedBy: .equal,
                           toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: -rightPadding).isActive = true
        NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal,
                           toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        
        
        
        // Register for device rotation notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRotate(notification:)),
                                               name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func didRotate(notification: Notification) {
        // Layout the view/subviews again
        DispatchQueue.main.async {
            // Set frame for self
            self.frame = self.controller?.frameForView() ?? .zero
        }
    }
    
    // MARK: Actions
    
    @objc private func buttonTapped(sender: UIButton) {
        // Notify controller that button was tapped
        controller?.viewButtonTapped()
    }
    
    // MARK: Subviews
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    open lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(self.buttonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
