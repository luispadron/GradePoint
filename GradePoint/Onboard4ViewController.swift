//
//  Onboard3ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/20/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing

class Onboard4ViewController: UIViewController {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var button: UIButton!
    
    private var hasAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set initial alpha for the views
        self.headerLabel.alpha = 0.0
        self.progressRing.alpha = 0.0
        self.button.alpha = 0.0
        
        // Set the style for the UIButton
        self.button.contentEdgeInsets = UIEdgeInsetsMake(12, 18, 12, 18)
        self.button.layer.backgroundColor = self.view.backgroundColor?.lighter(by: 20)?.cgColor
        self.button.layer.cornerRadius = 6.0
        
        self.progressRing.font = UIFont.systemFont(ofSize: 60)
        // Customization for progress ring
        self.progressRing.animationStyle = kCAMediaTimingFunctionEaseInEaseOut
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimated { self.animateViews() }
        self.hasAnimated = true
    }

    // MARK: Animations
    
    func animateViews() {
        UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: [], animations: {
            // Set the opacity for the views
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: { 
                self.headerLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                self.progressRing.alpha = 1.0
            })
            
        }) { (finished) in
            if finished {
                // Animate the progress ring
                self.progressRing.setProgress(value: 100, animationDuration: 2.0, completion: { [weak self] in
                    // When done animate the button alpha
                    UIView.animate(withDuration: 0.5, animations: { 
                        self?.button.alpha = 1.0
                    })
                })
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func onButtonTap(_ sender: UIButton) {
        // Set the has onboarded use to true
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: UserPreferenceKeys.onboardingComplete.rawValue)
    }
    
}
