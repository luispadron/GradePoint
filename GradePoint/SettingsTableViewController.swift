//
//  SettingsTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var studentTypeSwitcher: UISegmentedControl!
    
    // Constants for the rows and sections
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set version number
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        // TableView customization
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
        
        // Set inital student type switcher to whatever value we have in the stored preferences
        let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: UserDefaultKeys.studentType.rawValue))
        studentTypeSwitcher.selectedSegmentIndex = (studentType?.rawValue ?? 0) - 1
        
        self.title = "Settings"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
            return 3
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
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        switch section {
        case 0:
            label.text = "Info"
        case 1:
            label.text = "Configuration"
        case 2:
            label.text = "Contact"
        case 3:
            label.text = "Legal"
        default:
            return nil
        }
        
        return mainView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            switch indexPath.row {
            case 0:
                let presentError = { self.presentErrorAlert(title: "Unable to email", message: "Couldn't open email client.\nFeel free to email me at Luis@luispadron.com") }
                let toEmail = "luis@luispadron.com"
                if let subject = "Contact From GradePoint".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let url = URL(string: "mailto:\(toEmail)?subject=\(subject)") {
                    if !UIApplication.shared.openURL(url) { presentError() }
                } else {
                    presentError()
                }
            case 1:
                UIApplication.shared.openURL(URL(string: "http://gradepoint.luispadron.com")!)
            case 2:
                UIApplication.shared.openURL(URL(string: "https://github.com/luispadron")!)
            default:
                return
            }
        default:
            return
        }
    }
    
    // MARK: Actions
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
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
            defaults.set(type.rawValue, forKey: UserDefaultKeys.studentType.rawValue)
            
            // Update all the classes depending on type switched to
            let realm = try! Realm()
            let classes = realm.objects(Class.self)
            
            switch type {
            case .college:
                for classObj in classes {
                    try! realm.write {
                        // Update all class types to college, and credits to 3
                        classObj.classType = .college
                        classObj.creditHours = 3
                    }
                }
            case .highSchool:
                for classObj in classes {
                    try! realm.write {
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

}
