//
//  BlurAlertController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/25/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BlurAlertController: UIViewController {
    
    @IBOutlet var alertBox: UIView!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    // The title and message labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    // MARK: - Properties
    
    var effect: UIVisualEffect!
    var alertTitle: String?
    var alertMessage: NSAttributedString?
    var buttonText: String?
    var buttonColor: UIColor?
    var animationDuration: TimeInterval?
    var delegate: BlurAlertControllerDelegate?
    
    var shouldBlur = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        
        if UIAccessibilityIsReduceTransparencyEnabled() { // User has disabled transparency, lets just present a normal modal dialogue
            // Dont show blur 
            shouldBlur = false
            alertBox.backgroundColor = UIColor.white
        }
        
        // Initialization code, set some properties and some styling up
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        
        alertBox.layer.cornerRadius = 5
        alertBox.clipsToBounds = true
        
        // Add bottom border to alertBox for the titlelabel
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: alertBox.layer.frame.minX, y: titleLabel.frame.height, width: alertBox.layer.frame.width, height: 1)
        bottomBorder.backgroundColor = UIColor.gray.cgColor
        alertBox.layer.addSublayer(bottomBorder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the text
        titleLabel.text = alertTitle ?? "Title"
        let message = alertMessage ?? NSAttributedString(string: "Message")
        messageLabel.attributedText = message
        // Set button attributes
        button.setTitle(buttonText ?? "Done", for: .normal)
        button.backgroundColor = buttonColor ?? UIColor.blue
        
        alertBox.center = self.view.center
        // Animate
        animateIn()
    }
    
    // MARK: - IBActions
    
    @IBAction func buttonTouched(_ sender: AnyObject) {
        animteOutAndDismiss()
    }
    
    // MARK: - Helper Methods
    
    func animateIn() {
        self.view.addSubview(alertBox)
        
        // Start the view invisible and at the top most of the VC
        alertBox.center.y = self.view.frame.minY // Start off at the top
        alertBox.alpha = 0.0
        
        let duration = animationDuration ?? 0.5
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 30.0, options: .curveEaseInOut, animations: {
            if self.shouldBlur { self.visualEffectView.effect = self.effect }
            self.alertBox.center = self.view.center
            self.alertBox.alpha = 1.0
            
            }, completion: nil)
    }
    
    func animteOutAndDismiss() {
        let duration = animationDuration ?? 0.5
        // Animate the view out
        UIView.animate(withDuration: duration, animations: {
            if self.shouldBlur { self.visualEffectView.effect = nil }
            self.alertBox.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            self.alertBox.alpha = 0
            self.alertBox.center.y = self.view.frame.maxY
            }) { _ in
                self.dismiss(animated: false, completion: {
                    // Call the delegate
                    self.delegate?.alertDidFinish()
                })
        }
    }

}

