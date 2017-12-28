//
//  SettingsTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import LPSnackbar

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var studentTypeSwitcher: UISegmentedControl!
    @IBOutlet weak var themeSwitcher: UISegmentedControl!
    @IBOutlet weak var roundingField: UISafeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch UIColor.theme {
        case .dark: navigationController?.navigationBar.barStyle = .black
        case .light: navigationController?.navigationBar.barStyle = .default
        }

        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        // Set version number
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        // TableView customization
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
        
        // Set inital student type switcher to whatever value we have in the stored preferences
        let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: userDefaultStudentType))
        studentTypeSwitcher.selectedSegmentIndex = (studentType?.rawValue ?? 1) - 1

        // Set initial theme for theme switcher
        let theme = UITheme(rawValue: UserDefaults.standard.integer(forKey: userDefaultTheme))
        themeSwitcher.selectedSegmentIndex = (theme?.rawValue ?? 1) - 1
        
        // Rounding field setup
        let roundingAmount = UserDefaults.standard.integer(forKey: userDefaultRoundingAmount)
        self.roundingField.text = String(roundingAmount)
        self.roundingField.fieldType = .number
        var config = NumberConfiguration(allowsSignedNumbers: false, range: 1...3)
        config.allowsFloating = false
        self.roundingField.configuration = config
        self.roundingField.delegate = self
        self.roundingField.textAlignment = .right
        self.roundingField.returnKeyType = .done
        // Add toolbar to rounding field
        let fieldToolbar = UIToolbar()
        fieldToolbar.barStyle = .default
        fieldToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.accessoryKeyboardDone))
        ]
        fieldToolbar.sizeToFit()
        fieldToolbar.barTintColor = UIColor.lightBackground
        fieldToolbar.isTranslucent = false
        self.roundingField.inputAccessoryView = fieldToolbar

        // Setup tableview estimates
        self.tableView.estimatedRowHeight = 44
        self.tableView.estimatedSectionHeaderHeight = 30
        self.tableView.estimatedSectionFooterHeight = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor.background
        self.tableView.separatorColor = UIColor.tableViewSeperator
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Save any changes done to rounding amount to user defaults
        guard let amount = Int(self.roundingField.safeText) else { return }
        UserDefaults.standard.set(amount, forKey: userDefaultRoundingAmount)
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 5
        case 2:
            return 3
        case 3:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        // Set text color for label and highlight color if view has a segemented control
        for view in cell.contentView.subviews {
            if let label = view as? UILabel {
                label.textColor = UIColor.mainTextColor()
            } 
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Info"
        case 1: return "Configuration"
        case 2: return "Contact"
        case 3: return "Legal"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.tableViewHeader
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.textColor = UIColor.tableViewHeaderText
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            switch indexPath.row {
            case 0:
                if let subject = "Contact From GradePoint".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                    let url = URL(string: "mailto:\(contactEmail)?subject=\(subject)")
                {
                    if !UIApplication.shared.openURL(url) {
                        LPSnackbar.showSnack(title: "Email me @ \(contactEmail)")
                    }
                } else {
                    LPSnackbar.showSnack(title: "Email me @ \(contactEmail)")
                }
            case 1:
                UIApplication.shared.openURL(URL(string: "http://gradepoint.luispadron.com")!)
            case 2:
                UIApplication.shared.openURL(URL(string: "https://github.com/luispadron")!)
            default:
                return
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func semesterSegmentChanged(_ sender: UISegmentedControl) {
        // User tapped to change, let make sure to inform them what will happen
        let title = "Change Student Type"
        var message = ""
        
        if sender.selectedSegmentIndex == 0 {
            // User switching to college from highschol
            message = "Switching student type to college will change all your classes to college.\nAre you sure?"
        } else {
            // User switching to highschool from college
            message = "Switching student type to highschool will change all your classes to regular highschool classes.\nAre you sure?"
        }
        
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200),
                                          title: NSAttributedString(string: title), message: NSAttributedString(string: message))
        // Create the buttons for the alert
        let ok = UIButton()
        ok.setTitle("OK", for: .normal)
        ok.setTitleColor(.white, for: .normal)
        ok.backgroundColor = UIColor.warning
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(.white, for: .normal)
        cancel.backgroundColor = UIColor.info
        
        
        // Add the buttons and their handlers
        alert.addButton(button: cancel) { [weak self] in
            // Reset the button
            let prevIndex = sender.selectedSegmentIndex > 0 ? 0 : 1
            self?.studentTypeSwitcher.selectedSegmentIndex = prevIndex
        }
        
        alert.addButton(button: ok) {
            // Save the value switched to the databse
            // Update the user defaults key
            let defaults = UserDefaults.standard
            let type  = sender.selectedSegmentIndex == 0 ? StudentType.college : StudentType.highSchool
            defaults.set(type.rawValue, forKey: userDefaultStudentType)
            
            // Update all the classes depending on type switched to
            let realm = DatabaseManager.shared.realm
            let classes = realm.objects(Class.self)
            
            switch type {
            case .college:
                for classObj in classes {
                    DatabaseManager.shared.write {
                        // Update all class types to college, and credits to 3
                        classObj.classType = .college
                        classObj.creditHours = 3
                    }
                }
            case .highSchool:
                for classObj in classes {
                    DatabaseManager.shared.write {
                        // Update all class types to regular, and credits to 1
                        classObj.classType = .regular
                        classObj.creditHours = 1
                    }
                }
            }
            
        }
        
        // Present the alert
        alert.presentAlert(presentingViewController: self)
    }

    @IBAction func themeSegmentChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex + 1
        guard let theme = UITheme(rawValue: index) else { return }
        // Update theme
        UserDefaults.standard.set(index, forKey: userDefaultTheme)
        (UIApplication.shared.delegate as? AppDelegate)?.setUITheme(for: theme)
        // Animate
        animateThemeChange()
    }

    private func animateThemeChange(duration: TimeInterval = 0.35) {
        // Create the scale animation

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        // The animation layer which will be added ontop of the buttons current layer
        let animationLayer = CALayer()
        var radius = max(self.view.frame.width, self.view.frame.height)
        radius += radius * 0.40
        animationLayer.frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        animationLayer.position = self.view.center
        animationLayer.cornerRadius = radius/2
        animationLayer.opacity = 0.98
        animationLayer.backgroundColor = UIColor.background.cgColor

        // Set completion
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // Remove layer
            animationLayer.removeFromSuperlayer()
        }

        animationLayer.add(scaleAnimation, forKey: "pulse")
        // Finally add the layer to the top most view, this way it covers everything
        self.tabBarController?.view.layer.addSublayer(animationLayer)
        // Set timer to update UI
        Timer.scheduledTimer(timeInterval: duration * 0.80, target: self, selector: #selector(self.updateUIForThemeChanges),
                             userInfo: nil, repeats: false)
        CATransaction.commit()
    }

    @objc private func updateUIForThemeChanges() {
        // Since this view wont update until shown again, update nav and tab bar and cells right now
        switch UIColor.theme {
        case .dark:
            navigationController?.navigationBar.barStyle = .black
        case .light:
            navigationController?.navigationBar.barStyle = .default
        }

        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mainTextColor()]
        navigationController?.navigationBar.tintColor = UIColor.highlight
        navigationController?.navigationBar.barTintColor = UIColor.lightBackground
        tabBarController?.tabBar.tintColor = UIColor.highlight
        tabBarController?.tabBar.barTintColor = UIColor.lightBackground
        self.view.backgroundColor = UIColor.background
        self.tableView.separatorColor = UIColor.tableViewSeperator

        self.tableView.reloadData()

        // Post notification to allow any other view controllers that need to update their UI
        NotificationCenter.default.post(name: themeUpdatedNotification, object: nil)
    }
    
    @objc private func accessoryKeyboardDone() {
        self.roundingField.resignFirstResponder()
        // Save to defaults
        guard let amount = Int(self.roundingField.safeText) else { return }
        UserDefaults.standard.set(amount, forKey: userDefaultRoundingAmount)
    }
}

// MARK: Delegation for `roundingField`

extension SettingsTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return self.roundingField.shouldChangeTextAfterCheck(text: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
