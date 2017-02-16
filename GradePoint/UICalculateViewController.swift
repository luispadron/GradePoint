//
//  UICalculateViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/16/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UICalculateViewController: UIViewController {
    
    open var viewSize: CGSize
    open var animationDuration: TimeInterval = 0.5
    open lazy var calculateView: UICalculateView = {
        let view = UICalculateView(frame: CGRect(origin: .zero, size: self.viewSize))
        return view
    }()
    
    required public init(size: CGSize) {
        self.viewSize = size
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.calculateView.center = self.view.center
        self.calculateView.backgroundColor = UIColor.sunsetOrange
        self.view.addSubview(calculateView)
        self.view.backgroundColor = UIColor.lapisLazuli
        
        // Add constraints
        let widthConstraint = NSLayoutConstraint(item: calculateView, attribute: .width, relatedBy: .equal, toItem: nil,
                                                 attribute: .notAnAttribute, multiplier: 1.0, constant: self.calculateView.frame.width)
        let heightConstraint = NSLayoutConstraint(item: calculateView, attribute: .height, relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute, multiplier: 1.0, constant: self.calculateView.frame.height)
        let xConstraint = NSLayoutConstraint(item: calculateView, attribute: .centerX, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerX, multiplier: 1.0, constant: 0)
        let yConstraint = NSLayoutConstraint(item: calculateView, attribute: .centerY, relatedBy: .equal, toItem: self.view,
                                             attribute: .centerY, multiplier: 1.0, constant: 0)
        NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
    }

}
