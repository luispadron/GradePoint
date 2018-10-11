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
        self.toggleViewVisibility(to: true)
        self.setupUI()
        self.updateUI(with: UIDevice.current.orientation, size: self.view.frame.size)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
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
        self.updateUI(with: UIDevice.current.orientation, size: size)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ApplicationTheme.shared.statusBarStyle
    }

    // MARK: Helpers

    /// Sets up the UI with the correct text for labels/colors
    public func setupUI() {
        // UI setup
        view.backgroundColor = ApplicationTheme.shared.backgroundColor

        bgView.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
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
        titleLabel.textColor = ApplicationTheme.shared.mainTextColor()

        gradeLabel.text = gradeString
        
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
        if UIDevice.current.userInterfaceIdiom == .pad {
            updateUIForIpad(size: size)
        } else {
            updateUIForIphone(size: size)
        }
    }
    
    private func updateUIForIphone(size: CGSize) {
        switch UIDevice.current.orientation {
        case .landscapeLeft: fallthrough
        case .landscapeRight:
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 15
                self.bgViewBottomCons.constant = 15
                if size.width < 500 {
                    self.bgViewLeadingCons.constant = 70
                    self.bgViewTrailingCons.constant = 70
                } else {
                    self.bgViewLeadingCons.constant = 140
                    self.bgViewTrailingCons.constant = 140
                }
            }
            break
            
        case .portraitUpsideDown: fallthrough
        case .portrait:
            DispatchQueue.main.async {
                self.bgViewLeadingCons.constant = 15
                self.bgViewTrailingCons.constant = 15
                if size.height < 600 {
                    self.bgViewTopCons.constant = 50
                    self.bgViewBottomCons.constant = 50
                } else {
                    self.bgViewTopCons.constant = 90
                    self.bgViewBottomCons.constant = 90
                }
            }
            break
            
        default:
            // If cant determine orientation for some reason fall back
            print("\(#file) \(#line) WARNING: Unable to determine orientation for device.")
            DispatchQueue.main.async {
                self.bgViewLeadingCons.constant = 15
                self.bgViewTrailingCons.constant = 15
                self.bgViewTopCons.constant = 50
                self.bgViewBottomCons.constant = 50
            }
            break
        }
    }
    
    private func updateUIForIpad(size: CGSize) {
        DispatchQueue.main.async {
            self.titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
            self.button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
            self.gradeLabel.font = UIFont.systemFont(ofSize: 100)
        }
        
        switch UIDevice.current.orientation {
        case .landscapeLeft: fallthrough
        case .landscapeRight:
            DispatchQueue.main.async {
                self.bgViewTopCons.constant = 40
                self.bgViewBottomCons.constant = 40
                self.bgViewLeadingCons.constant = 80
                self.bgViewTrailingCons.constant = 80
            }
            break
            
        case .portraitUpsideDown: fallthrough
        case .portrait:
            DispatchQueue.main.async {
                self.bgViewLeadingCons.constant = 25
                self.bgViewTrailingCons.constant = 25
                self.bgViewTopCons.constant = 160
                self.bgViewBottomCons.constant = 160
            }
            break
            
        default:
            // If cant determine orientation for some reason fall back
            print("\(#file) \(#line) WARNING: Unable to determine orientation for device.")
            DispatchQueue.main.async {
                self.bgViewLeadingCons.constant = 15
                self.bgViewTrailingCons.constant = 15
                self.bgViewTopCons.constant = 50
                self.bgViewBottomCons.constant = 50
            }
            break
        }
    }
    
    /// Hides all the views, this will be done if a class is deleted, and the application is in split screen mode
    public func toggleViewVisibility(to visible: Bool) {

        self.title = visible ? "Previous Class" : nil
        
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
                tabBar.children.count > 1,
                let calcsVC = tabBar.children[1] as? CalculatorsViewController else {
                    
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
    @IBOutlet weak var titleLabelTopCons: NSLayoutConstraint!
    @IBOutlet weak var buttonBottomCons: NSLayoutConstraint!
}
