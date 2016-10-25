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
    var alertMessage: String?
    var buttonText: String?
    var buttonColor: UIColor?
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
        titleLabel.layer.borderWidth = 2
        titleLabel.layer.cornerRadius = 5
        titleLabel.clipsToBounds = true
        titleLabel.layer.borderColor = UIColor.unselected.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the text
        titleLabel.text = alertTitle ?? "Title"
        messageLabel.text = alertMessage ?? "Message"
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
        
        // Offset
        alertBox.center.y = self.view.frame.minY // Start off at the top
        
        alertBox.alpha = 0
        
        let animationDuration = 0.5
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: [], animations: { 
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 2/3, animations: {
                if self.shouldBlur { self.visualEffectView.effect = self.effect }
                self.alertBox.center = self.view.center
                self.alertBox.alpha = 1.0
            })
            
            // Bounce up
            UIView.addKeyframe(withRelativeStartTime: 0.7, relativeDuration: 1/3, animations: {
                self.alertBox.center.y -= 30
            })
            
            // Bounce down
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 1/3, animations: {
                self.alertBox.center.y += 30
            })
        })

    }
    
    func animteOutAndDismiss() {

        UIView.animate(withDuration: 0.4, animations: {
            if self.shouldBlur { self.visualEffectView.effect = nil }
            self.alertBox.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
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
