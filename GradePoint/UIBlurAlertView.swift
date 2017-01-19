//
//  UIBlurAlertView.swift
//  GradePoint
//
//  Created by Luis Padron on 1/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UIBlurAlertView: UIView {
    
    // MARK: - Properties
    
    private var _title: NSAttributedString
    
    public var title: NSAttributedString {
        get { return self._title }
    }
    
    private var _message: NSAttributedString?
    
    public var message: NSAttributedString? {
        get { return self._message}
    }
    
    private lazy var titleLabel = UILabel()
    private lazy var messageLabel = UILabel()
    private lazy var buttons = [UIButton]()
    
    // MARK: - Initializers
    
    public required init(frame: CGRect, title: NSAttributedString, message: NSAttributedString?) {
        self._title = title
        self._message = message
        super.init(frame: frame)
        self.drawViews()
    }
    
    // Not used
    private override init(frame: CGRect) {
        fatalError("Please use init(frame: CGRect, title: String, message: String?) instead")
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("initCoder not set up for UIBlurAlertView")
    }
    
    // MARK: - Helpers
    
    private func drawViews() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        titleLabel.attributedText = _title
        titleLabel.textAlignment = .center
        messageLabel.attributedText = _message
        messageLabel.textAlignment = .center
        
        // Set up frames
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 30)
        messageLabel.frame = CGRect(x: 0, y: titleLabel.frame.height + 25, width: self.bounds.width, height: 30)
        messageLabel.resizeToFitText()
        
        self.addSubview(titleLabel)
        self.addSubview(messageLabel)
        
        
        // Add a border to view
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: self.layer.frame.minX, y: titleLabel.frame.height, width: self.layer.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomBorder)
    }
}
