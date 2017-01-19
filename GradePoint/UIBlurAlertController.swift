//
//  UIBlurAlertController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UIBlurAlertController: UIViewController {
    
    // MARK: - Properties
    
    /// The size of the alert dialog
    public var alertSize: CGSize
    private var _alertTitle: NSAttributedString
    /// The title for the alert
    public var alertTitle: NSAttributedString {
        get { return self._alertTitle }
    }
    private var _message: NSAttributedString?
    /// The message for the alert
    public var message: NSAttributedString? {
        get { return self._message }
    }
    /// The background color for the alert
    public var alertBackgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.85)
    /// The visual effect view
    private var visualEffectView: UIVisualEffectView?
    /// The visual effect for the controller
    private var effect: UIVisualEffect?
    /// The blur effect for the controller, default = Dark
    public var blurEffect = UIBlurEffect(style: .dark)
    /// The animation duration for the animation in and the animation out of the alert view. Default = 0.5
    public var animationDuration: TimeInterval = 0.5
    
    private lazy var alertView: UIBlurAlertView = {
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.alertSize)
        let view = UIBlurAlertView(frame: frame, title: self.alertTitle, message: self.message)
        return view
    }()
    
    // MARK: - Initializers
    
    required public init(size alertSize: CGSize, title: NSAttributedString, message: NSAttributedString?) {
        self.alertSize = alertSize
        self._alertTitle = title
        self._message = message
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overCurrentContext
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        // Create blur effect view and add it as a subview
        self.addVisualEffectView()
        
        // Add the blur alert view
        self.alertView.center = self.view.center
        self.alertView.backgroundColor = alertBackgroundColor
        self.view.addSubview(alertView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if animated {
            self.animateIn()
        }
    }

    open override func viewWillLayoutSubviews() {
        self.alertView.center = self.view.center
    }
    
    // MARK: - Presenting Method
    
    /// Call this to present the alert, because this will override the animation since doing custom animation
    public func presentAlert(presentingViewController pvc: UIViewController) {
        pvc.present(self, animated: false, completion: nil)
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
    
    /// Animates the alertview in
    private func animateIn() {
        // Start the view invisible and at the top
        alertView.center.y = self.view.bounds.minY
        alertView.alpha = 0.0
        
        UIView.animate(withDuration: self.animationDuration, delay: 0.0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 7, options: .curveEaseInOut,
                       animations: {
                        // Add the blur back
                        if let view = self.visualEffectView { view.effect = self.blurEffect }
                        self.alertView.center = self.view.center
                        self.alertView.alpha = 1.0
                       }, completion: nil)
    }
}
