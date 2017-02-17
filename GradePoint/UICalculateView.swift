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
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        // Add subviews
        // Set frames for subviews
        let frameForTitle = CGRect(x: 0, y: 5, width: self.bounds.width, height: 20)
        titleLabel.frame = frameForTitle
        self.addSubview(titleLabel)
        
        let frameForScore = CGRect(x: 5, y: frameForTitle.maxY + 15, width: self.bounds.width - 10, height: 40)
        scoreField.frame = frameForScore
        self.addSubview(scoreField)
        
        let frameForTotal = CGRect(x: 5, y: frameForScore.maxY + 15, width: self.bounds.width - 10, height: 40)
        totalField.frame = frameForTotal
        self.addSubview(totalField)
        
        let sizeForButton = CGSize(width: 150, height: 40)
        let pointForButton = CGPoint(x: self.bounds.midX - (sizeForButton.width/2), y: frameForTotal.maxY + 10)
        calculateButton.frame = CGRect(origin: pointForButton, size: sizeForButton)
        self.addSubview(calculateButton)
        
        // Add a border to view
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 5, width: self.layer.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
    
    // MARK: - Actions
    
    @objc private func calculateButtonTapped(button: UIButton) {
        button.animateWithPulse(withDuration: 0.3) {
            print("Animated")
        }
    }
    
    // MARK: - Subviews
    
    /// The title label which will be displayed ontop of the view
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Calculate Percentage"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.lightText
        label.textAlignment = .center
        return label
    }()
    
    /// The score UIFloatingPromptTextField view
    open lazy var scoreField: UIFloatingPromptTextField = {
        let config = NumberConfiguration(allowsSignedNumbers: false)
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .number, configuration: config)
        field.placeholder = "Score"
        field.titleText = "Score"
        field.titleTextSpacing = 8.0
        field.font = UIFont.systemFont(ofSize: 18)
        field.attributedPlaceholder = NSAttributedString(string: "Score", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.delegate = self
        return field
    }()
    
    /// The total UISafeTextField view
    open lazy var totalField: UIFloatingPromptTextField = {
        let config = NumberConfiguration(allowsSignedNumbers: false)
        let field = UIFloatingPromptTextField(frame: .zero, fieldType: .number, configuration: config)
        field.placeholder = "Total"
        field.titleText = "Total"
        field.titleTextSpacing = 8.0
        field.font = UIFont.systemFont(ofSize: 18)
        field.attributedPlaceholder = NSAttributedString(string: "Total", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.delegate = self
        return field
    }()
    
    /// The button which the user will click to calculate the percentage
    open lazy var calculateButton: UIButton = {
        let button = UIButton(type: .custom)
        let attrs = [NSForegroundColorAttributeName: UIColor.lightText, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        button.layer.backgroundColor = UIColor.green.cgColor
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.setAttributedTitle(NSAttributedString(string: "Calculate", attributes: attrs), for: .normal)
        button.addTarget(self, action: #selector(self.calculateButtonTapped), for: .touchUpInside)
        return button
    }()
}

// MARK: - UITextField Delegation

extension UICalculateView: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UIFloatingPromptTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
}
