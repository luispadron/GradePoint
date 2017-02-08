//
//  UIBlurAlertController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import AudioToolbox.AudioServices

open class UIBlurAlertController: UIViewController {
    
    // MARK: - Properties
    
    /// The size of the alert dialog
    open var alertSize: CGSize
    private var _alertTitle: NSAttributedString
    /// The title for the alert
    open var alertTitle: NSAttributedString {
        get { return self._alertTitle }
    }
    private var _message: NSAttributedString?
    /// The message for the alert
    open var message: NSAttributedString? {
        get { return self._message }
    }
    /// The background color for the alert
    open var alertBackgroundColor = UIColor(colorLiteralRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.85)
    /// The visual effect view
    private var visualEffectView: UIVisualEffectView?
    /// The visual effect for the controller
    private var effect: UIVisualEffect?
    /// The blur effect for the controller, default = Dark
    open var blurEffect = UIBlurEffect(style: .dark)
    /// The animation duration for the animation in and the animation out of the alert view. Default = 0.5
    open var animationDuration: TimeInterval = 0.5
    /// The alert view for the controller
    private lazy var alertView: UIBlurAlertView = {
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.alertSize)
        let view = UIBlurAlertView(frame: frame, title: self.alertTitle, message: self.message)
        return view
    }()
    /// The feed back type for this alert, if set will trigger a haptic feedback if on iOS 10 +
    open var alertFeedbackType: UINotificationFeedbackType?
    
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
        self.alertView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(alertView)
        
        // Add constraints
        let widthConstraint = NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1.0, constant: self.alertView.frame.width)
        let heightConstraint = NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1.0, constant: self.alertView.frame.height)
        let xConstraint = NSLayoutConstraint(item: alertView, attribute: .centerX, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if animated {
            self.animateIn()
        }
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.visualEffectView?.frame = self.view.frame
    }
    
    // MARK: - Presenting Method
    
    /// Call this to present the alert, because this will override the animation since doing custom animation
    public func presentAlert(presentingViewController pvc: UIViewController, completion: (() -> Void)? = nil) {
        pvc.present(self, animated: false, completion: completion)
    }
    
    // MARK: - Button actions
    
    public func addButton(button: UIButton, forHandlerEvents events: UIControlEvents = [.touchUpInside], handler: (() -> Void)?) {
        self.alertView.buttons.append(button)
        // Add the action to the button
        if let h = handler {
            button.addHandler(forEvents: events, handler: { [weak self] in
                h()
                self?.animateOutAndDismiss()
            })
        } else { // Handler is nil, when button gets clicked just dismiss the controller
            button.addHandler(forEvents: events, handler: { [weak self] in
                self?.animateOutAndDismiss()
            })
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
    
    /// Animates the alertview in
    private func animateIn() {
        // Start the view invisible and at the top
        alertView.center.y = self.view.bounds.minY
        alertView.alpha = 0.0
        
        UIView.animate(withDuration: self.animationDuration, delay: 0.0,
                       usingSpringWithDamping: 1.0, initialSpringVelocity: 9, options: .curveEaseInOut,
                       animations: {
                        // Add the blur back
                        if let view = self.visualEffectView { view.effect = self.blurEffect }
                        self.alertView.center = self.view.center
                        self.alertView.alpha = 1.0
                       }, completion: nil)
        
        // Will do a haptic feed back vibration if on iOS 10+ and alertFeedback is set
        if let type = alertFeedbackType, #available(iOS 10.0, *) {
            let notificationGenerator = UINotificationFeedbackGenerator()
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(type)
        }
    }
    
    private func animateOutAndDismiss() {
        UIView.animate(withDuration: self.animationDuration, animations: { 
            // Remove the effect
            if let view = self.visualEffectView { view.effect = nil }
            self.alertView.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            self.alertView.alpha = 0
            self.alertView.center.y = self.view.frame.maxY
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}
