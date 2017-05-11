//
//  Onboard2ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/19/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class Onboard2ViewController: UIViewController {

    // MARK: Views
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var classAddExample: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var rubricStackView: UIStackView!
    @IBOutlet weak var rubricView1: UIImageView!
    @IBOutlet weak var rubricView2: UIImageView!
    @IBOutlet weak var rubricView3: UIImageView!
    @IBOutlet weak var rubricView4: UIImageView!
    @IBOutlet weak var swipeLabel: UILabel!
    
    private var hasAnimated = false
    private var yForRubricView2: CGFloat = 0.0
    private var yForRubricView3: CGFloat = 0.0
    private var yForRubricView4: CGFloat = 0.0
    
    private var previousFrame: CGRect? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set opacity for views
        firstLabel.alpha = 0.0
        secondLabel.alpha = 0.0
        swipeLabel.alpha = 0.0
        classAddExample.alpha = 0.0
        rubricView1.alpha = 0.0
        rubricView2.alpha = 0.0
        rubricView3.alpha = 0.0
        rubricView4.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAnimated { self.animateViews() }
        self.hasAnimated = true
    }
    
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        updateUI(withOrientation: toInterfaceOrientation)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if previousFrame != self.view.bounds {
            updateUI(withOrientation: UIApplication.shared.statusBarOrientation)
        }
        
        previousFrame = self.view.bounds
    }
    
    private func updateUI(withOrientation orientation: UIInterfaceOrientation) {
        let height = self.view.bounds.height

        if UIDevice.current.userInterfaceIdiom == .pad && height < 1000 {
            switch orientation {
            case .portraitUpsideDown: fallthrough
            case .portrait:
                rubricView3.alpha = 1.0
                rubricView4.alpha = 1.0
                rubricStackView.addArrangedSubview(rubricView3)
                rubricStackView.addArrangedSubview(rubricView4)
            case .unknown: fallthrough
            case .landscapeLeft: fallthrough
            case .landscapeRight:
                rubricView3.removeFromSuperview()
                rubricView4.removeFromSuperview()
            }
        }
    }
    

    func animateViews() {
        // Set the old y origins for the rubric views
        yForRubricView2 = self.rubricView2.center.y
        yForRubricView3 = self.rubricView3.center.y
        yForRubricView4 = self.rubricView4.center.y
        // Now 'collapse' all the rubrics onto rubric 1
        self.rubricView2.center.y = self.rubricView1.center.y
        self.rubricView3.center.y = self.rubricView1.center.y
        self.rubricView4.center.y = self.rubricView1.center.y
        
        
        let duration: TimeInterval = 2.0
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: {
                self.firstLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                self.classAddExample.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                self.secondLabel.alpha = 1.0
            })
            
            
        }) { _ in
            self.animateRubricViews()
        }
    }
    
    func animateRubricViews() {
        let duration: TimeInterval = 4.0
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: [], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/5, animations: {
                self.rubricView1.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/5, relativeDuration: 1/5, animations: {
                self.rubricView2.alpha = 1.0
                self.rubricView2.center.y = self.yForRubricView2
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/5, relativeDuration: 1/5, animations: {
                if self.rubricStackView.arrangedSubviews.contains(self.rubricView3) {
                    self.rubricView3.alpha = 1.0
                    self.rubricView3.center.y = self.yForRubricView3
                }
            })
            
            UIView.addKeyframe(withRelativeStartTime: 3/5, relativeDuration: 1/5, animations: {
                if self.rubricStackView.arrangedSubviews.contains(self.rubricView4) {
                    self.rubricView4.alpha = 1.0
                    self.rubricView4.center.y = self.yForRubricView4
                }
            })
            
            UIView.addKeyframe(withRelativeStartTime: 4/5, relativeDuration: 1/5, animations: { 
                self.swipeLabel.alpha = 1.0
            })
            
        }) { _ in
            // Keep animating swipe label
            UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: .repeat, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.swipeLabel.alpha = 0.5
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                    self.swipeLabel.alpha = 1.0
                })
                
            }, completion: nil)
        }
    }
    
}
