//
//  Onboard1ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/19/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class Onboard1ViewController: UIViewController {

    // MARK: - Views
    @IBOutlet weak var introView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var swipeLabel: UILabel!
    
    private let animationDuration = 1.5
    private var hasAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set opacity to zero for all the views
        headerLabel.alpha = 0.0
        appIcon.alpha = 0.0
        detailLabel.alpha = 0.0
        swipeLabel.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Animate the views
        if !hasAnimated {
            // View did appear was getting called to fast which caused animation to not show on initial presentation.
            // Perform animation for this controller 0.5 seconds after appearing
            self.perform(#selector(self.animateViews), with: nil, afterDelay: 0.5)
        }
        hasAnimated = true
    }
    
    // MARK: Animations
    func animateViews() {
        // Animate icon size up and back down
        self.appIcon.transform = CGAffineTransform.init(scaleX: 0.0, y: 0.0)
        
        UIView.animateKeyframes(withDuration: animationDuration/2, delay: 0.0, options: [.beginFromCurrentState, .calculationModeCubic], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1, animations: { 
                self.appIcon.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                self.appIcon.transform = CGAffineTransform.init(scaleX: 1.1, y: 1.1)
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                self.appIcon.transform = CGAffineTransform.identity
            })
            
        }) { (finished) in
            if finished { self.animateLabels() }
        }
        
    }
    
    func animateLabels() {
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                self.headerLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                self.detailLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: { 
                self.swipeLabel.alpha = 1.0
            })
            
        }, completion: { (finished) in
            // Keep animating the alpha value for the swipe label
            if finished {
                UIView.animateKeyframes(withDuration: self.animationDuration, delay: 0.0, options: .repeat, animations: {
                    
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: { 
                        self.swipeLabel.alpha = 0.5
                    })
                    
                    UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                        self.swipeLabel.alpha = 1.0
                    })
                    
                }, completion: nil)
            }
        })
    }

}
