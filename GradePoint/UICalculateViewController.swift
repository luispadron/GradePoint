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
        let view = UICalculateView(frame: CGRect(origin: self.view.center, size: CGSize(width: 320, height: 220)))
        view.delegate = self
        return view
    }()
    
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
        
        // Add constraints
        let widthConstraint = NSLayoutConstraint(item: calculateView, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1.0, constant: calculateView.frame.width)
        let heightConstraint = NSLayoutConstraint(item: calculateView, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1.0, constant: calculateView.frame.height)
        let xConstraint = NSLayoutConstraint(item: calculateView, attribute: .centerX, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: calculateView, attribute: .centerY, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
        
        // Add recognizer to view
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewWasTapped))
        self.view.addGestureRecognizer(tap)
    }
    
    // MARK: Actions
    
    func viewWasTapped(recognizer: UITapGestureRecognizer) {
        let tapPoint = recognizer.location(in: self.view)
        if calculateView.frame.contains(tapPoint) { return }
        else { self.animateOut(completion: nil) }
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
        let percent = (((Double(score) ?? 0.0) / totalSafe) * 100.0).roundedUpTo(2)
        
        
        self.animateOut { [weak self] _ in
            self?.calculationCompletion(percent)
        }
    }
    
    func exitButtonWasTapped(for: UICalculateView) {
        self.animateOut(completion: nil)
    }
}
