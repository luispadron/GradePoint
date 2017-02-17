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
    
    open var calculationCompletion: CalculateViewControllerCompletion
    
    open lazy var calculateView: UICalculateView = {
        let view = UICalculateView(frame: CGRect(origin: self.view.center, size: CGSize(width: 320, height: 220)))
        view.delegate = self
        return view
    }()
    
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
        
    }
}

/// MARK: - UICalculateView Delegation

extension UICalculateViewController: UICalculateViewDelegate {
    func calculateWasTapped(for: UICalculateView, score: String, total: String) {
        let totalD = Double(total) ?? 1.0
        let totalSafe = totalD > 0.0 ? totalD : 1.0
        let p = ((Double(score) ?? 0.0) / totalSafe) * 100.0
        
        let percent = Double(round(100 * p)/100)
        
        self.dismiss(animated: false) { [weak self] in
            self?.calculationCompletion(percent)
        }
    }
    
    func exitButtonWasTapped(for: UICalculateView) {
        super.animateOut { finished in
            if finished { self.dismiss(animated: false, completion: nil) }
        }
    }
}
