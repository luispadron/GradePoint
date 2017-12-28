//
//  UICalculateViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UICalculateViewController: UIBlurViewController {
    
    /// The percent of the calculated view
    public typealias CalculateViewControllerCompletion = (Double) -> Void
    
    /// The completion for the calculate view, will be called when calculate button is pressed
    open var calculationCompletion: CalculateViewControllerCompletion
    
    /// The calculate view instance
    open lazy var calculateView: UICalculateView = {
        let view = UICalculateView(frame: CGRect(origin: self.view.center, size: CGSize(width: 310, height: 210)))
        view.delegate = self
        return view
    }()
    
    private var calcViewYConstraint: NSLayoutConstraint?
    private var calcViewInitialY: CGFloat?
    
    // MARK: Initializers
    
    required public init(completion: @escaping CalculateViewControllerCompletion) {
        self.calculationCompletion = completion
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(calculateView)
        calculateView.center = self.view.center
        
        let width = self.view.frame.width > 310 ? 310 : self.view.frame.width - 15
        let height: CGFloat = 210.0
        // Add constraints
        let widthConstraint = NSLayoutConstraint(item: calculateView, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1.0, constant: width)
        let heightConstraint = NSLayoutConstraint(item: calculateView, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1.0, constant: height)
        let xConstraint = NSLayoutConstraint(item: calculateView, attribute: .centerX, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerX, multiplier: 1.0, constant: 0)
        self.calcViewYConstraint = NSLayoutConstraint(item: calculateView, attribute: .centerY, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, self.calcViewYConstraint!])
        
        // Add recognizer to view
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        self.view.addGestureRecognizer(tap)
        
        // Register for keyboard notifications
        // If not on iPad where the view will be presented as a popover
        if !(UIDevice.current.userInterfaceIdiom == .pad) {
            // Setup keyboard notifications
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardDidShow),
                                                   name: .UIKeyboardDidShow, object: nil)
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(keyboardWillHide),
                                                   name: .UIKeyboardWillHide, object: nil)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.calcViewInitialY = self.calcViewYConstraint?.constant
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove notifications for keyboard
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Actions
    
    @objc func viewWasTapped(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: self.view)
        if calculateView.frame.contains(tapPoint) { return }
        else { self.animateOut(completion: nil) }
    }
    
    /// Called whenever keyboard is shown, adjusts scroll view
    @objc func keyboardDidShow(notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        if (self.calculateView.frame.maxY) >= keyboardFrame.minY {
            // Calculate view is covered adjust height
            self.calcViewYConstraint?.constant -= (self.calculateView.frame.maxY - keyboardFrame.minY) + 10
        }
    }
    
    /// Called whenever keyboard is shown, adjusts scroll view
    @objc func keyboardWillHide(notification: Notification) {
        // Revert constraint
        self.calcViewYConstraint?.constant = self.calcViewInitialY ?? self.view.center.y
    }
    
    // MARK: Animations
    
    public override func animateIn(completion: UIBlurViewController.BlurViewAnimationCompletion?) {
        super.animateIn(completion: completion)
        // Custom animation code for calculate view
        self.calculateView.alpha = 0.0
        self.calculateView.transform = CGAffineTransform.init(scaleX: 0.2, y: 0.2)
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 10,
                       options: [.beginFromCurrentState, .curveEaseOut],
                       animations: {
                        self.calculateView.alpha = 1.0
                        self.calculateView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
        }) { finished in
            if finished { completion?(finished) }
        }
    }
    
    public override func animateOut(completion: UIBlurViewController.BlurViewAnimationCompletion?) {
        super.animateOut(completion: completion)
        // Custom animation code for calculate view
        self.calculateView.alpha = 1.0
        UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 5, options: .curveEaseIn,
                       animations: { 
                        self.calculateView.alpha = 0.0
                        self.calculateView.transform = CGAffineTransform.init(scaleX: 0.3, y: 0.3)
        }) { finished in
            if finished { completion?(finished) }
        }
    }
}

/// MARK: - UICalculateView Delegation

extension UICalculateViewController: UICalculateViewDelegate {
    func calculateWasTapped(for: UICalculateView, score: String, total: String) {
        let totalD = Double(total) ?? 1.0
        let totalSafe = totalD > 0.0 ? totalD : 1.0
        let roundingAmount = UserDefaults.standard.integer(forKey: userDefaultRoundingAmount)
        let percent = (((Double(score) ?? 0.0) / totalSafe) * 100.0).roundedUpTo(roundingAmount)
        
        
        self.animateOut { [weak self] _ in
            self?.calculationCompletion(percent)
        }
    }
    
    func exitButtonWasTapped(for: UICalculateView) {
        self.animateOut(completion: nil)
    }
}
