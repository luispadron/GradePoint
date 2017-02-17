//
//  UIBlurAlertView.swift
//  GradePoint
//
//  Created by Luis Padron on 1/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

internal class UIBlurAlertView: UIView {
    
    // MARK: - Properties
    
    private var _title: NSAttributedString
    
    internal var title: NSAttributedString {
        get { return self._title }
    }
    
    private var _message: NSAttributedString?
    
    internal var message: NSAttributedString? {
        get { return self._message}
    }
    
    private lazy var titleLabel = UILabel()
    private lazy var messageLabel = UILabel()
    internal var buttons = [UIButton]() {
        didSet {
            self.updateButtons()
        }
    }
    
    // MARK: - Initializers
    
    internal required init(frame: CGRect, title: NSAttributedString, message: NSAttributedString?) {
        self._title = title
        self._message = message
        super.init(frame: frame)
        self.drawViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    private func updateButtons() {
        // Loop through all the buttons and add them
        for (index, button) in buttons.enumerated() {
            // Calculate the size and positions
            let width = self.bounds.width / CGFloat(buttons.count)
            let height = self.bounds.height * 1/4
            let xForButton: CGFloat = width * CGFloat(index)
            let yForButton: CGFloat = self.bounds.maxY - height
            button.frame = CGRect(x: xForButton, y: yForButton, width: width, height: height)
            // If already added, then just continue and dont add the button as a subview again
            if let _ = self.subviews.index(of: button) { continue }
            self.addSubview(button)
        }
    }
}
