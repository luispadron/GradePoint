//
//  Onboard3ViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 4/8/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class Onboard3ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var schoolTypeLabel: UILabel!
    @IBOutlet weak var schoolTypeSegmentControl: UISegmentedControl!
    @IBOutlet weak var gradingTypeLabel: UILabel!
    @IBOutlet weak var gradingTypeSegementControl: UISegmentedControl!
    
    weak var pageController: OnboardPageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Actions
    
    @IBAction func schoolTypeChanged(_ sender: UISegmentedControl) {
        pageController?.dataSource = nil
        pageController?.dataSource = pageController!
    }
    
    
    @IBAction func gradingTypeChanged(_ sender: UISegmentedControl) {
        pageController?.dataSource = nil
        pageController?.dataSource = pageController!
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
