//
//  UIBlurAlertController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/17/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class UIBlurAlertController: UIViewController {
    
    public var alertSize: CGSize
    
    private var _alertTitle: NSAttributedString
    public var alertTitle: NSAttributedString {
        get { return self._alertTitle }
    }
    
    private var _message: NSAttributedString?
    public var message: NSAttributedString? {
        get { return self._message }
    }
    
    private lazy var alertView: UIBlurAlertView = {
        let frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.alertSize)
        let view = UIBlurAlertView(frame: frame, title: self.alertTitle, message: self.message)
        return view
    }()
    
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.clear
        
        // Add the blur alert view
        self.alertView.center = self.view.center
        self.view.addSubview(alertView)
    }

    open override func viewWillLayoutSubviews() {
        self.alertView.center = self.view.center
    }
    
    
}
