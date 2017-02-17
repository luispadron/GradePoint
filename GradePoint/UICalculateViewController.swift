//
//  UICalculateViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UICalculateViewController: UIViewController {
    
    open var animationDuration: TimeInterval = 0.5
    open lazy var calculateView: UICalculateView = {
        let view = UICalculateView(frame: CGRect(origin: self.view.center, size: CGSize(width: 300, height: 220)))
        return view
    }()
    
    required public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
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
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = UIColor.gray
    }

}
