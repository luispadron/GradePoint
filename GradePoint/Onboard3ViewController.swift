//
//  Onboard3ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 4/8/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class Onboard3ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var gradingTypeLabel: UILabel!
    @IBOutlet weak var gradingTypeSegementControl: UISegmentedControl!
    @IBOutlet weak var swipeLabel: UILabel!
    
    /// Reference to the parent controller
    weak var pageController: OnboardPageViewController?
    /// Determines whether we have previously animated the grading type segment and label, if so, don't animate again
    var hasAnimatedGradingType = false
    /// Determines whether we have started the animation for the swipe label, if so, dont start it again
    var hasStartedSwipeAnimation = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // UI Set up, make all alphas 0, since I suck at animations and alpha animations are easy
        titleLabel.alpha = 0.0
        schoolTypeLabel.alpha = 0.0
        schoolTypeSegmentControl.alpha = 0.0
        gradingTypeLabel.alpha = 0.0
        gradingTypeSegementControl.alpha = 0.0
        swipeLabel.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Animate the views
        self.animateViews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Customize font size for segmented control
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            switch traitCollection.horizontalSizeClass {
            case .compact:
                schoolTypeSegmentControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], for: .normal)
                gradingTypeSegementControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 16)], for: .normal)
            case .unspecified: fallthrough
            case .regular:
                schoolTypeSegmentControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25)], for: .normal)
                gradingTypeSegementControl.setTitleTextAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 25)], for: .normal)
            }
            
        }
    }
    
    func animateViews() {
        // First animate the title, school type label and segment control
        // When user selects a school type, animate the grading type segment
        UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: { 
                self.titleLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                self.schoolTypeLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                self.schoolTypeSegmentControl.alpha = 1.0
            })
            
        }, completion: nil)
    }

    // MARK: Actions
    
    @IBAction func schoolTypeChanged(_ sender: UISegmentedControl) {
        pageController?.dataSource = nil
        pageController?.dataSource = pageController!
        
        // If we haven't animated before, then animate the grading type label and control in now
        if !hasAnimatedGradingType {
            UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.gradingTypeLabel.alpha = 1.0
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                    self.gradingTypeSegementControl.alpha = 1.0
                })
            }, completion: nil)
        }
        
        // Update the user defaults key
        let defaults = UserDefaults.standard
        let type  = sender.selectedSegmentIndex == 0 ? StudentType.college : StudentType.highSchool
        defaults.set(type.rawValue, forKey: UserPreferenceKeys.studentType.rawValue)
    }
    
    
    @IBAction func gradingTypeChanged(_ sender: UISegmentedControl) {
        pageController?.dataSource = nil
        pageController?.dataSource = pageController!
        
        // If we haven't animated the swipe label, do so now
        if !hasStartedSwipeAnimation {
            self.swipeLabel.alpha = 1.0
            UIView.animateKeyframes(withDuration: 1.5, delay: 0.0, options: .repeat, animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.swipeLabel.alpha = 0.5
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                    self.swipeLabel.alpha = 1.0
                })
                
            }, completion: nil)
        }
        
        let type  = sender.selectedSegmentIndex == 0 ? GPAScaleType.plusScale : GPAScaleType.nonPlusScale
        // Create the grading scale
        GPAScale.createScale(forType: type)
    }
    
    // MARK: Helpers
    
    /// Returns whether values are filled and can move on to next ViewController
    var isReadyToTransition: Bool {
        get {
            let schoolReady = self.schoolTypeSegmentControl.selectedSegmentIndex >= 0
            let gradeReady = self.gradingTypeSegementControl.selectedSegmentIndex >= 0
            return schoolReady && gradeReady
        }
    }

}
