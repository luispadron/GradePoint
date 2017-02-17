//
//  UIBlurViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/// A view controller which presents a blurred view
open class UIBlurViewController: UIViewController {

    /// The visual effect view
    open var visualEffectView: UIVisualEffectView?
    /// The visual effect for the controller
    open var effect: UIVisualEffect?
    /// The blur effect for the controller, default = Dark
    open var blurEffect = UIBlurEffect(style: .dark)
    /// The animation duration for the animation in and the animation out of the blur view. Default = 0.5
    open var animationDuration: TimeInterval = 0.5
    
    convenience init(animationDuration: TimeInterval) {
        self.init()
        self.animationDuration = animationDuration
        self.modalPresentationStyle = .overCurrentContext
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        // Add the visual effect view as a subview
        self.addVisualEffectView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if animated { self.animateIn() }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.visualEffectView?.frame = self.view.frame
    }
    
    // MARK: - Animations
    
    public typealias BlurViewAnimationCompletion = (Bool) -> Void
    
    /// Animates the blur when appearing
    public func animateIn(completion: BlurViewAnimationCompletion? = nil) {
        
        UIView.animate(withDuration: self.animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 9,
                       options: .curveEaseInOut, animations: { 
                        // Add the blur back
                        if let view = self.visualEffectView { view.effect = self.blurEffect }
        }) { (finished) in
            if finished { completion?(finished) }
        }
        
    }
    
    /// Animates the blur view out
    public func animateOut(completion: BlurViewAnimationCompletion? = nil) {
        UIView.animate(withDuration: self.animationDuration, animations: {
            // Remove the effect
            if let view = self.visualEffectView { view.effect = nil }
        }) { (finished) in
            if finished { completion?(finished) }
        }
    }
    
    // MARK: - Helpers
    
    /// Adds a visual effect view over the controller, only if allowed by user settings
    private func addVisualEffectView() {
        if UIAccessibilityIsReduceTransparencyEnabled() { return }
        // Create the effect since user allows blur
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.view.bounds
        self.view.addSubview(blurView)
        
        // Vibrancy effect
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.frame = self.view.bounds
        blurView.contentView.addSubview(vibrancyView)
        
        self.effect = blurView.effect
        blurView.effect = nil
        self.visualEffectView = blurView
    }


}
