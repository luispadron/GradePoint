//
//  LPRatingView.swift
//  LPIntegratedRating
//
//  Created by Luis Padron on 6/27/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

internal extension UIColor {
    static let defaultColor: UIColor = UIColor(red: 0.310, green: 0.325, blue: 0.616, alpha: 1.00)
}

open class LPRatingView: UIView {
    
    // MARK: Properties
    
    open weak var delegate: LPRatingViewDelegate?
    
    private var state: LPRatingViewState = .initial
    
    open var animationDuration: TimeInterval = 1.5
    
    open var buttonOffset: CGFloat = 15.0
    open var buttonSpacing: CGFloat = 10.0
    
    private lazy var defaultConfiguration: LPRatingViewConfiguration = {
        // Fallback and use default config
        let title = NSAttributedString(string: "Default view configuration, change it!",
                                       attributes: [.foregroundColor: UIColor.white])
        let approvalTitle = NSAttributedString(string: "Default yes",
                                               attributes: [.foregroundColor: UIColor.defaultColor])
        let rejectionTitle = NSAttributedString(string: "Default no",
                                                attributes: [.foregroundColor: UIColor.white])
        return LPRatingViewConfiguration(title: title,
                                         approvalButtonTitle: approvalTitle,
                                         rejectionButtonTitle: rejectionTitle)
    }()
    
    // MARK: Overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        intitialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intitialize()
    }
    
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Layout title
        titleLabel.frame = CGRect(x: 0, y: 0,
                                  width: bounds.width, height: bounds.height/2)
        
        // Layout buttons
        rejectionButton.sizeToFit()
        rejectionButton.frame = CGRect(x: buttonOffset,
                                       y: titleLabel.frame.maxY,
                                       width: bounds.width/2 - buttonOffset - buttonSpacing,
                                       height: rejectionButton.bounds.height)
        approvalButton.sizeToFit()
        approvalButton.frame = CGRect(x: bounds.maxX - rejectionButton.bounds.width - buttonOffset,
                                      y: titleLabel.frame.maxY,
                                      width: bounds.width/2 - buttonOffset - buttonSpacing,
                                      height: approvalButton.bounds.height)
        
        if let config = delegate?.ratingViewConfiguration(for: state) {
            updateView(with: config)
        } else {
            // Fallback and use default config
            updateView(with: defaultConfiguration)
        }
    }
    
    // MARK: Methods
    
    private func intitialize()  {
        self.translatesAutoresizingMaskIntoConstraints = false
        // Add subviews
        self.addSubview(titleLabel)
        self.addSubview(approvalButton)
        self.addSubview(rejectionButton)
        
        // Custom button drawing
        approvalButton.layer.masksToBounds = false
        approvalButton.layer.cornerRadius = 5.0
        approvalButton.layer.borderWidth = 1.0
        approvalButton.layer.borderColor = UIColor.white.cgColor
        
        rejectionButton.layer.masksToBounds = false
        rejectionButton.layer.cornerRadius = 5.0
        rejectionButton.layer.borderWidth = 1.0
        rejectionButton.layer.borderColor = UIColor.white.cgColor
        
    }
    
    private func transition(to state: LPRatingViewState) {
        // Tell delegate to animate out out
        delegate?.performOutAnimation(for: self, from: self.state, to: state)
        // Update config
        if let config = delegate?.ratingViewConfiguration(for: state) {
            updateView(with: config)
        } else {
            // Fallback and use default config
            updateView(with: defaultConfiguration)
        }
        // Tell delegate to animate the view back in
        delegate?.performInAnimation(for: self, from: self.state, to: state)
        
        
        // Finally set the current state
        self.state = state
    }
    
    private func updateView(with config: LPRatingViewConfiguration) {
        self.backgroundColor = config.backgroundColor
        titleLabel.attributedText = config.title
        approvalButton.setAttributedTitle(config.approvalButtonTitle, for: .normal)
        approvalButton.backgroundColor = config.approvalButtonColor
        rejectionButton.setAttributedTitle(config.rejectionButtonTitle, for: .normal)
        rejectionButton.backgroundColor = config.rejectionButtonColor
    }
    
    // MARK: Actions
    
    @objc func approvalButtonTouched(button: UIButton) {
        // Based on current state determine state to transition to, or whether to call view completion
        switch self.state {
        case .initial:
            transition(to: .approval)
        case .approval:
            // User approved twice
            delegate?.ratingViewDidFinish(with: .ratingApproved)
        case .rejection:
            // User denied initally then approved
            delegate?.ratingViewDidFinish(with: .feedbackApproved)
        }
    }
    
    @objc func rejectionButtonTouched(button: UIButton) {
        switch self.state {
        case .initial:
            transition(to: .rejection)
        case .approval:
            // User rejected after initial ask
            delegate?.ratingViewDidFinish(with: .ratingDenied)
        case .rejection:
            // User rejected initially and then again
            delegate?.ratingViewDidFinish(with: .feedbackDenied)
        }
    }
    
    
    // MARK: Subviews
    
    lazy open var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    lazy open var approvalButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(self.approvalButtonTouched), for: .touchUpInside)
        return button
    }()
    
    lazy open var rejectionButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(self.rejectionButtonTouched), for: .touchUpInside)
        return button
    }()
}
