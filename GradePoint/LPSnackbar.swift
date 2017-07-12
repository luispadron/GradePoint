//
//  LPSnackbar.swift
//  GradePoint
//
//  Created by Luis Padron on 7/11/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class LPSnackbar {
    
    // MARK: Public Members
    
    open lazy var view: LPSnackbarView = {
        let snackView = LPSnackbarView(frame: .zero)
        snackView.controller = self
        snackView.isHidden = true
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
    
    open var animationDuration: TimeInterval = 0.5
    
    public typealias SnackbarCompletion = (Bool) -> Void
    
    // MARK: Private Members
    
    private var displayTimer: Timer?
    private var displayDuration: TimeInterval?
    
    private var wasAnimated: Bool = false
    
    private var completion: SnackbarCompletion?
    
    // MARK: Initializers
    
    public init (title: String, buttonTitle: String?, displayDuration: TimeInterval? = 5.0) {
        self.displayDuration = displayDuration
        
        // Set labels/buttons
        view.titleLabel.text = title
        if let _ = buttonTitle {
            view.button.setTitle(buttonTitle, for: .normal)
        } else {
            // Remove button
            view.button.removeFromSuperview()
        }
        
        // Finish initialization
        finishInit()
    }
    
    public init(attributedTitle: NSAttributedString, attributedButtonTitle: NSAttributedString?, displayDuration: TimeInterval? = 5.0) {
        self.displayDuration = displayDuration
        
        // Set labels/buttons
        view.titleLabel.attributedText = attributedTitle
        if let _ = attributedButtonTitle {
            view.button.setAttributedTitle(attributedButtonTitle, for: .normal)
        } else {
            // Remove button
            view.button.removeFromSuperview()
        }
        
        // Finish initialization
        finishInit()
    }
    
    private func finishInit() {
        guard let window = UIApplication.shared.keyWindow else {
            print("Unable to get window, was not able to add LPSnackbarView as a subview to the main UIWindow")
            return
        }
        
        // Add to window
        window.addSubview(view)
        
        // Set timer for when view will be removed
        if let duration = displayDuration {
            displayTimer = Timer.scheduledTimer(timeInterval: duration,
                                                target: self,
                                                selector: #selector(self.timerDidFinish),
                                                userInfo: nil,
                                                repeats: false)
        }
    }
    
    
    // MARK: Helper Methods
    
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
    
    private func prepareForRemoval() {
        view.controller = nil
        view.removeFromSuperview()
    }
    
    // MARK: Animation
    
    private func animateIn() {
        let frame = frameForView()
        let inY = frame.origin.y
        let outY = frame.origin.y + height + bottomSpacing
        // Set up view outside the frame, then animate it back in
        view.isHidden = false
        let oldOpacity = view.layer.opacity
        view.layer.opacity = 0.0
        view.frame = CGRect(x: frame.origin.x, y: outY, width: frame.width, height: frame.height)
        
        UIView.animate(
            withDuration: animationDuration,
            delay: 0.1,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.0,
            options: .curveEaseInOut,
            animations: {
                // Animate the view to the correct position & opacity
                self.view.layer.opacity = oldOpacity
                self.view.frame = CGRect(x: frame.origin.x, y: inY, width: frame.width, height: frame.height)
            },
            completion: nil
        )
        
        wasAnimated = true
    }
    
    private func animateOut(completion: SnackbarCompletion?, wasButtonTapped: Bool = false) {
        let frame = view.frame
        let outY = frame.origin.y + height + bottomSpacing
        
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                self.view.frame = CGRect(x: frame.origin.x, y: outY, width: frame.width, height: frame.height)
                self.view.layer.opacity = 0.0
            },
            completion: { _ in
                // Call the completion handler
                completion?(wasButtonTapped)
                // Prepare to deinit
                self.prepareForRemoval()
            }
        )
    }
    
    // MARK: Actions
    
    @objc private func timerDidFinish() {
        if wasAnimated {
            self.animateOut(completion: completion)
        } else {
            // Call the completion handler, since no animation will be shown
            completion?(false)
            // Prepare to deinit
            prepareForRemoval()
        }
    }
    
    internal func viewButtonTapped() {
        // If timer is active, invalidate since view will now dissapear no matter what
        displayTimer?.invalidate()
        displayTimer = nil
        
        if wasAnimated {
            // Animate the view out, which will in turn call the completion handler
            self.animateOut(completion: completion, wasButtonTapped: true)
        } else {
            // Call the completion handler, since no animation will be shown
            completion?(true)
            // Prepare to deinit
            prepareForRemoval()
        }
    }
    
    // MARK: Public Methods
    
    open func show(animated: Bool = true, completion: SnackbarCompletion? = nil) {
        self.completion = completion
        
        if animated {
            animateIn()
        } else {
            view.isHidden = false
        }
    }
    
    open func remove(animated: Bool = true) {
        if animated {
            self.animateOut(completion: completion)
        } else {
            prepareForRemoval()
        }
    }
    
    // MARK: Deinit
    
    deinit {
        print("Snackbar has been deinitialized")
        view.controller = nil
        view.removeFromSuperview()
    }
}
