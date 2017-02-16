//
//  UICalculateView.swift
//  GradePoint
//
//  Created by Luis Padron on 2/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/// A view which calculates a percentage given the score and total
open class UICalculateView: UIView {
    
    // MARK: - Initalizers & Overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Methods
    
    private func initialize() {
        // Add subviews
        // Set frames for subviews
        let frameForTitle = CGRect(x: 0, y: 0, width: self.frame.width, height: 20)
        titleLabel.frame = frameForTitle
        self.addSubview(titleLabel)
        
        let frameForScore = CGRect(x: 5, y: frameForTitle.maxY + 20, width: self.bounds.width - 5, height: 30)
        scoreField.frame = frameForScore
        self.addSubview(scoreField)
        
        let frameForTotal = CGRect(x: 5, y: frameForScore.maxY + 25, width: self.bounds.width - 5, height: 30)
        totalField.frame = frameForScore
        self.addSubview(totalField)
        
        let sizeForButton = CGSize(width: 100, height: 30)
        let pointForButton = CGPoint(x: self.bounds.midX - 50, y: self.bounds.midY + frameForTotal.maxY + 20)
        calculateButton.frame = CGRect(origin: pointForButton, size: sizeForButton)
        self.addSubview(totalField)
        
        // Add a border to view
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: self.layer.frame.minX, y: titleLabel.frame.height, width: self.layer.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
    
    // MARK: - Actions
    
    @objc private func calculateButtonTapped(button: UIButton) {
        print("button touched")
    }
    
    // MARK: - Subviews
    
    /// The title label which will be displayed ontop of the view
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Calculate Percentage"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.lapisLazuli
        label.contentMode = .center
        return label
    }()
    
    /// The score UIFloatingPromptTextField view
    open lazy var scoreField: UIFloatingPromptTextField = {
        let config = NumberConfiguration(allowsSignedNumbers: false)
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .number, configuration: config)
        field.placeholder = "Score"
        field.titleText = "Score"
        field.font = UIFont.systemFont(ofSize: 18)
        field.attributedPlaceholder = NSAttributedString(string: "Score", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        return field
    }()
    
    /// The total UISafeTextField view
    open lazy var totalField: UIFloatingPromptTextField = {
        let config = NumberConfiguration(allowsSignedNumbers: false)
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .number, configuration: config)
        field.placeholder = "Total"
        field.titleText = "Total"
        field.font = UIFont.systemFont(ofSize: 18)
        field.attributedPlaceholder = NSAttributedString(string: "Total", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        return field
    }()
    
    /// The button which the user will click to calculate the percentage
    open lazy var calculateButton: UIButton = {
        let button = UIButton(type: .custom)
        let attrs = [NSForegroundColorAttributeName: UIColor.lightText, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        button.setAttributedTitle(NSAttributedString(string: "Calculate", attributes: attrs), for: .normal)
        button.addTarget(self, action: #selector(self.calculateButtonTapped), for: .allTouchEvents)
        return button
    }()
}
