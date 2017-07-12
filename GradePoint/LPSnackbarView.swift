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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set frame for self
        self.frame = controller?.frameForView() ?? .zero

        // Set frame for subviews
        let labelWidth = bounds.width * 0.75
        titleLabel.frame = CGRect(x: leftPadding, y: 0, width: labelWidth, height: bounds.height)
        button.frame = CGRect(x: labelWidth + leftPadding * 2, y: 0, width: bounds.width * 0.25 - leftPadding, height: bounds.height)
    }
    
    // MARK: Private methods
    
    private func initialize() {
        // Customize UI
        backgroundColor = UIColor(red: 0.180, green: 0.180, blue: 0.180, alpha: 1.00)
        layer.opacity = 0.95
        translatesAutoresizingMaskIntoConstraints = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5.0
        layer.shadowOpacity = 0.5
        layer.cornerRadius = 5.0
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(button)
        
        // Register for device rotation notifications
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didRotate(notification:)),
                                               name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc private func didRotate(notification: Notification) {
        // Layout the view/subviews again
        DispatchQueue.main.async {
            self.setNeedsLayout()
        }
    }
    
    // MARK: Actions
    
    @objc private func buttonTapped(sender: UIButton) {
        print("Tap")
    }
    
    // MARK: Subviews
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .left
        label.textColor = UIColor.white
        return label
    }()
    
    open lazy var button: UIButton = {
        let button = UIButton(frame: .zero)
        button.addTarget(self, action: #selector(self.buttonTapped(sender:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: Deinit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
