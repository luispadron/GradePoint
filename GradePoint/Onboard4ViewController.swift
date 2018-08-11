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
    @IBOutlet weak var progressRing: UICircularProgressRing!
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
        
        // Customization for progress ring
        self.progressRing.animationStyle = kCAMediaTimingFunctionEaseInEaseOut
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAnimated { self.animateViews() }
        self.hasAnimated = true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Customize font size/ring properties
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            switch traitCollection.horizontalSizeClass {
            case .compact:
                progressRing.font = UIFont.systemFont(ofSize: 60)
                progressRing.outerRingWidth = 14
                progressRing.innerRingWidth = 10
            case .unspecified: fallthrough
            case .regular:
                progressRing.font = UIFont.systemFont(ofSize: 90)
                progressRing.outerRingWidth = 20
                progressRing.innerRingWidth = 16
            }
            
        }
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
            
        }) { _ in
            // Animate the progress ring
            self.progressRing.startProgress(to: 100, duration: 2.0, completion: { [weak self] in
                // When done animate the button alpha
                UIView.animate(withDuration: 0.5, animations: {
                    self?.button.alpha = 1.0
                })
            })
        }
    }
    
    // MARK: Actions
    
    @IBAction func onButtonTap(_ sender: UIButton) {
        // Set the has onboarded user to true
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: kUserDefaultOnboardingComplete)
        // Notify delegate were done onboarding
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.finishedPresentingOnboarding()
    }
    
}
