//
//  PreviousClassDetailViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 7/10/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import CoreMotion

class PreviousClassDetailViewController: UIViewController {
    
    // MARK: Properties
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradeHolderView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    public var className: String? = nil
    public var gradeString: String? = nil
    public var classColor: UIColor? = nil
    
    private let fallbackColor: UIColor = UIColor(red: 0.647, green: 0.576, blue: 0.878, alpha: 1.00)
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        toggleViewVisibility(to: true)

        setupUI()

        updateUI(with: UIDevice.current.orientation, size: self.view.frame.size)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Hide all the views
        toggleViewVisibility(to: false)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Set full circle for radius
        gradeHolderView.layer.cornerRadius = gradeHolderView.frame.height / 2
        // Set font size for grade label
        gradeLabel.font = UIFont.systemFont(ofSize: CGFloat(Int(gradeHolderView.frame.width / 2.5)))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateUI(with: UIDevice.current.orientation, size: size)
    }

    // MARK: Helpers

    /// Sets up the UI with the correct text for labels/colors
    public func setupUI() {
        // UI setup
        view.backgroundColor = UIColor.background

        bgView.backgroundColor = UIColor.lightBackground
        bgView.layer.cornerRadius = 10
        bgView.layer.shadowColor = UIColor.black.cgColor
        bgView.layer.shadowOffset = CGSize(width: 0, height: 0)
        bgView.layer.shadowOpacity = 0.5
        bgView.layer.shadowRadius = 10.0

        gradeHolderView.layer.shadowColor = UIColor.black.cgColor
        gradeHolderView.layer.shadowOffset = CGSize(width: 0, height: 0)
        gradeHolderView.layer.shadowOpacity = 0.4
        gradeHolderView.layer.shadowRadius = 5.0

        button.layer.cornerRadius = 10

        titleLabel.text = className
        titleLabel.textColor = UIColor.mainTextColor()

        gradeLabel.text = gradeString

        topLabel.textColor = UIColor.mainTextColor()
        bottomLabel.textColor = UIColor.mainTextColor()

        if let classColor = self.classColor {
            gradeHolderView.backgroundColor = classColor
            button.layer.backgroundColor = classColor.cgColor
            let visibleColor = classColor.visibleTextColor(lightColor: .lightText, darkColor: .darkText)
            gradeLabel.textColor = visibleColor
            button.setTitleColor(visibleColor, for: .normal)
            button.setTitleColor(visibleColor.darker(by: 20), for: .selected)
        } else {
            gradeHolderView.backgroundColor = fallbackColor
            button.layer.backgroundColor = fallbackColor.cgColor
            gradeLabel.textColor = .white
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.lightGray, for: .selected)
        }
    }
    
    /// Manages constraints and views depending on orientation and view size
    private func updateUI(with orientation: UIDeviceOrientation, size: CGSize) {
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        let isPortrait = orientation == .portrait || orientation == .portraitUpsideDown
        let isLandscape = orientation == .landscapeLeft || orientation == .landscapeRight
        let height = size.height

        guard !(UIDevice.current.orientation == .unknown) else {
            // Fall back and use the least amount of space
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 15
                self.bgViewBottomCons.constant = 15
                self.gradeHolderTopCons.constant = 15
                self.gradeHolderBottomCons.constant = 15
                self.buttonBottomCons.constant = 8
                self.topLabel.isHidden = true
                self.bottomLabel.isHidden = true
            }
            return
        }
        
        // If height is less than 700 (i.e, iPhone 6) and in portrait, remove the second label, and adjust constraints
        if  height < 700 && height > 600 && isPortrait {
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 70
                self.bgViewBottomCons.constant = 70
                self.gradeHolderTopCons.constant = 20
                self.gradeHolderBottomCons.constant = 20
                self.buttonBottomCons.constant = 12
                self.bottomLabel.isHidden = true
            }
        } else if height < 600 && isPortrait { // For screens smaller than iPhone 6, remove label, and adjust constraints
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 40
                self.bgViewBottomCons.constant = 40
                self.gradeHolderTopCons.constant = 10
                self.gradeHolderBottomCons.constant = 10
                self.buttonBottomCons.constant = 10
                self.bottomLabel.isHidden = true
            }
        } else if height < 600 && isLandscape {
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 15
                self.bgViewBottomCons.constant = 15
                self.gradeHolderTopCons.constant = 15
                self.gradeHolderBottomCons.constant = 15
                self.buttonBottomCons.constant = 8
            }
        } else if isIpad && isLandscape {
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 80
                self.bgViewBottomCons.constant = 80

                if height < 800 {
                    self.topLabel.isHidden = true
                    self.bottomLabel.isHidden = true
                } else {
                    self.gradeHolderBottomCons.constant = 40
                    self.bottomLabel.isHidden = false
                }
            }
        } else if isIpad && isPortrait {
            DispatchQueue.main.async {
                if height < 1200 {
                    self.bgViewTopCons.constant = 200
                    self.bgViewBottomCons.constant = 200
                    self.gradeHolderBottomCons.constant = 40
                    self.bottomLabel.isHidden = true
                    self.topLabel.isHidden = false
                } else {
                    self.bgViewTopCons.constant = 240
                    self.bgViewBottomCons.constant = 240
                    self.gradeHolderBottomCons.constant = 60
                    self.bottomLabel.isHidden = false
                    self.topLabel.isHidden = false
                }
            }
        }
    }
    
    /// Hides all the views, this will be done if a class is deleted, and the application is in split screen mode
    public func toggleViewVisibility(to visible: Bool) {

        self.title = visible ? className : nil
        
        bgView.isHidden = !visible
        titleLabel.isHidden = !visible
        gradeHolderView.isHidden = !visible
        gradeLabel.isHidden = !visible
        button.isHidden = !visible
    }
    
    // MARK: Actions
    
    @IBAction func buttonWasTapped(_ sender: UIButton) {
        button.animateWithPulse(withDuration: 0.2) {
            let window = (UIApplication.shared.delegate as! AppDelegate).window
            guard let tabBar = window?.rootViewController as? UITabBarController,
                tabBar.childViewControllers.count > 1,
                let calcsVC = tabBar.childViewControllers[1] as? CalculatorsViewController else {
                    
                    print("WARNING: Tried to find ClassesTableViewController but was not able.")
                    return
            }
            
            // Perform segue and show gpa calculator
            tabBar.selectedIndex = 1
            calcsVC.performSegue(withIdentifier: "presentGPACalculator", sender: nil)
        }
    }
    
    // MARK: View constraints
    @IBOutlet weak var bgViewTopCons: NSLayoutConstraint!
    @IBOutlet weak var bgViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var bgViewLeadingCons: NSLayoutConstraint!
    @IBOutlet weak var bgViewTrailingCons: NSLayoutConstraint!
    @IBOutlet weak var gradeHolderTopCons: NSLayoutConstraint!
    @IBOutlet weak var gradeHolderBottomCons: NSLayoutConstraint!
    @IBOutlet var bottomLabelConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var buttonBottomCons: NSLayoutConstraint!
}
