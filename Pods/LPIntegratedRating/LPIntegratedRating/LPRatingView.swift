//
//  LPRatingView.swift
//  LPIntegratedRating
//
//  Copyright (c) 2017 Luis Padron
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//  OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/// Internal extension to easily access the default color
internal extension UIColor {
    static let defaultColor: UIColor = UIColor(red: 0.310, green: 0.325, blue: 0.616, alpha: 1.00)
}

/**
 
 # LPRatingView
 
 This view contains a title: UILabel, an approvalButton: UIButton, and rejectionButton: UIButton.
 
 This is the main view which will display all the information according to the configuration set, using LPRatingViewConfiguration.
 This can be placed anywhere a UIView might be placed. However, it is highly recommended to integrate it into a table view or
 collectionview. Pop ups annoy the user and lead to lower app reviews. For easy integration check out `LPRatingTableViewCell`, and
 `LPRatingCollectionViewCell` which make it easy to use this view with either a `UITableView` or `UICollectionView`.
 
 */
open class LPRatingView: UIView {
    
    // MARK: Properties
    
    /**
     The delegate for the rating view, this will control the configuration and any completion states for the view
     */
    open weak var delegate: LPRatingViewDelegate?
    
    /**
     The current state of the view.
     
     ## Important:
     
     Default = `LPRatingViewState.initial`
     */
    private var state: LPRatingViewState = .initial
    
    /**
     The duration for the animation. This value will be divided by two once for animating the view out of the current state,
     and then again when animating the view into the next state
     
     ## Important:
     
     Default = 1.5
     */
    open var animationDuration: TimeInterval = 1.5
    
    /**
     The offset for both the leading and trailing edges.
     This will offset the button and give spacing between the edges of the view.
     
     ## Important:
     
     Default = 15.0
     */
    open var buttonOffset: CGFloat = 15.0
    
    /**
     The spacing between the buttons
     This will space the buttons out by the value assigned giving spacing in between the buttons.
     
     ## Important:
     
     Default = 10.0
     */
    open var buttonSpacing: CGFloat = 10.0
    
    /**
     The default configuration for the rating view.
     This is set to contain some basic styling and text, this must be changed by conforming to `LPRatingViewDelegate`
     and returning a configuration for each `LPRatingViewState`.
     */
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
    
    /// Overriden init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        intitialize()
    }
    
    /// Overriden init
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        intitialize()
    }
    
    /// Overriden layoutSubviews
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
        
        if let config = delegate?.ratingViewConfiguration(self, for: state) {
            updateView(with: config)
        } else {
            // Fallback and use default config
            updateView(with: defaultConfiguration)
        }
    }
    
    // MARK: Methods
    
    /// Initializes the rating view by adding subviews and performing extra customization such as borders for buttons, etc.
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
    
    /// Transitions the view to a certain state, asks the delegate for the configuration at that state.
    /// If configuration is not returned, falls back and uses `defaultConfiguration`.
    private func transition(to state: LPRatingViewState) {
        // Tell delegate to animate out out
        delegate?.performOutAnimation(for: self, from: self.state, to: state)
        // Update config
        if let config = delegate?.ratingViewConfiguration(self, for: state) {
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
    
    /// Updates the view and subviews with the passed in configuration
    private func updateView(with config: LPRatingViewConfiguration) {
        self.backgroundColor = config.backgroundColor
        titleLabel.attributedText = config.title
        approvalButton.setAttributedTitle(config.approvalButtonTitle, for: .normal)
        approvalButton.backgroundColor = config.approvalButtonColor
        rejectionButton.setAttributedTitle(config.rejectionButtonTitle, for: .normal)
        rejectionButton.backgroundColor = config.rejectionButtonColor
    }
    
    // MARK: Actions
    
    /// Listener for approval button touches
    @objc private func approvalButtonTouched(button: UIButton) {
        // Based on current state determine state to transition to, or whether to call view completion
        switch self.state {
        case .initial:
            transition(to: .approval)
        case .approval:
            // User approved twice
            delegate?.ratingViewDidFinish(self, with: .ratingApproved)
        case .rejection:
            // User denied initally then approved
            delegate?.ratingViewDidFinish(self, with: .feedbackApproved)
        }
    }
    
    /// Listener for rejection button touches
    @objc private func rejectionButtonTouched(button: UIButton) {
        switch self.state {
        case .initial:
            transition(to: .rejection)
        case .approval:
            // User rejected after initial ask
            delegate?.ratingViewDidFinish(self, with: .ratingDenied)
        case .rejection:
            // User rejected initially and then again
            delegate?.ratingViewDidFinish(self, with: .feedbackDenied)
        }
    }
    
    
    // MARK: Subviews
    
    /// The label which displays the title of the rating view
    lazy open var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    /// The approval button, touching this button will cause the delegate to be notified and may cause a state change
    lazy open var approvalButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(self.approvalButtonTouched), for: .touchUpInside)
        return button
    }()
    
    /// The rejection button, touching this button will cause the delegate to be notified and may cause a state change
    lazy open var rejectionButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.addTarget(self, action: #selector(self.rejectionButtonTouched), for: .touchUpInside)
        return button
    }()
}
