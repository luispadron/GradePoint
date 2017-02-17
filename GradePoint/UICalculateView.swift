//
//  UICalculateView.swift
//  GradePoint
//
//  Created by Luis Padron on 2/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/// Delegate for the calculate view
protocol UICalculateViewDelegate: class {
    func calculateWasTapped(for: UICalculateView, score: String, total: String)
    func exitButtonWasTapped(for: UICalculateView)
}

/// A view which calculates a percentage given the score and total
open class UICalculateView: UIView {
    
    weak var delegate: UICalculateViewDelegate?
    
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
        self.backgroundColor = UIColor(red: 0.878, green: 0.890, blue: 0.865, alpha: 1.0)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        // Add subviews
        // Set frames for subviews
        self.addSubview(headerView)
        
        let frameForScore = CGRect(x: 10, y: headerView.frame.maxY + 25, width: self.bounds.width - 20, height: 30)
        scoreField.frame = frameForScore
        self.addSubview(scoreField)
        
        let frameForSeperator = CGRect(x: 0, y: frameForScore.maxY + 10, width: self.bounds.width, height: seperatorLabel.frame.height)
        seperatorLabel.frame = frameForSeperator
        self.addSubview(seperatorLabel)
        
        let frameForTotal = CGRect(x: 10, y: frameForSeperator.maxY + 10, width: self.bounds.width - 20, height: 30)
        totalField.frame = frameForTotal
        self.addSubview(totalField)
        
        calculateButton.frame = CGRect(x: 0, y: self.bounds.maxY - 50, width: self.bounds.width, height: 50)
        self.addSubview(calculateButton)
        
        // Add a border to view
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0, y: titleLabel.frame.maxY + 5, width: self.layer.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor(red: 0.337, green: 0.384, blue: 0.439, alpha: 1.00).cgColor
        self.layer.addSublayer(bottomBorder)
    }
    
    
    // MARK: - Actions
    
    @objc private func calculateButtonTapped(button: UIButton) {
        button.animateWithPulse(withDuration: 0.3) { [weak self] in
            guard let `self` = self else { return }
            let score = self.scoreField.text ?? ""
            let total = self.totalField.text ?? ""
            self.delegate?.calculateWasTapped(for: self, score: score, total: total)
        }
    }
    
    @objc private func exitButtonTapped(button: UIButton) {
        self.delegate?.exitButtonWasTapped(for: self)
    }
    
    // MARK: - Subviews
    
    /// The enclosing header view, encapsulates the title label and the exit button
    open lazy var headerView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: 30)
        
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        view.addSubview(self.titleLabel)
        
        self.exitButton.frame = CGRect(x: view.bounds.width - 35, y: 4, width: 20, height: 20)
        view.addSubview(self.exitButton)
        
        return view
    }()
    
    /// The title label which will be displayed ontop of the view
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Calculate Percentage"
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor(red: 0.337, green: 0.384, blue: 0.439, alpha: 1.00)
        label.textAlignment = .center
        return label
    }()
    
    /// The exit button for the view
    open lazy var exitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "DeleteIcon"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(self.exitButtonTapped), for: .touchUpInside)
        return button
    }()
    
    /// The score UISafeTextField view
    open lazy var scoreField: UISafeTextField = {
        let config = NumberConfiguration(allowsSignedNumbers: false)
        let field = UISafeTextField(frame: .zero, fieldType: .number, configuration: config)
        field.placeholder = "Score"
        field.tintColor = UIColor(red: 0.647, green: 0.576, blue: 0.878, alpha: 1.00)
        field.font = UIFont.systemFont(ofSize: 18)
        field.borderStyle = .roundedRect
        field.attributedPlaceholder = NSAttributedString(string: "Score", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.delegate = self
        return field
    }()
    
    /// The label in between the score and total fields
    open lazy var seperatorLabel: UILabel = {
        let label = UILabel()
        let attrs = [NSForegroundColorAttributeName: UIColor.mutedText, NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
        label.attributedText = NSAttributedString(string: "OUT OF", attributes: attrs)
        label.textAlignment = .center
        label.resizeToFitText()
        return label
    }()
    
    /// The total UISafeTextField view
    open lazy var totalField: UISafeTextField = {
        let config = NumberConfiguration(allowsSignedNumbers: false)
        let field = UISafeTextField(frame: .zero, fieldType: .number, configuration: config)
        field.placeholder = "Total"
        field.borderStyle = .roundedRect
        field.tintColor = UIColor(red: 0.647, green: 0.576, blue: 0.878, alpha: 1.00)
        field.font = UIFont.systemFont(ofSize: 18)
        field.attributedPlaceholder = NSAttributedString(string: "Total", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        field.delegate = self
        return field
    }()
    
    /// The button which the user will click to calculate the percentage
    open lazy var calculateButton: UIButton = {
        let button = UIButton(type: .custom)
        let attrs = [NSForegroundColorAttributeName: UIColor.lightText, NSFontAttributeName: UIFont.systemFont(ofSize: 18)]
        button.layer.backgroundColor = UIColor(red: 0.647, green: 0.576, blue: 0.878, alpha: 1.00).cgColor
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
        guard let field = textField as? UISafeTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
}
