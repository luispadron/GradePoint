//
//  SettingsTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set version number
        versionLabel.text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        // TableView customization
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
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
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 2
        default:
            return 1
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
        case 1:
            if indexPath.row == 1 {
                // Warn the user about restoring settings
                let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200),
                                                  title: NSAttributedString(string: "Restore Defaults"),
                                                  message: NSAttributedString(string: "Are you sure you want to restore to default configuration?\nThis cannot be undone",
                                                                              attributes: [NSForegroundColorAttributeName: UIColor.sunsetOrange, NSFontAttributeName: UIFont.systemFont(ofSize: 14)]))
                let restore = UIButton()
                restore.setTitle("Restore", for: .normal)
                restore.setTitleColor(UIColor.white, for: .normal)
                restore.backgroundColor = UIColor.sunsetOrange
                let cancel = UIButton()
                cancel.setTitle("Cancel", for: .normal)
                cancel.setTitleColor(UIColor.white, for: .normal)
                cancel.backgroundColor = UIColor.lapisLazuli
                alert.addButton(button: cancel, handler: nil)
                alert.addButton(button: restore, handler: { 
                    // Handle restoring settings
                    GPAScale.restoreScale()
                })
                alert.presentAlert(presentingViewController: self)
                
            }
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
                UIApplication.shared.openURL(URL(string: "https://luispadron.com")!)
            case 2:
                UIApplication.shared.openURL(URL(string: "https://github.com/luispadron")!)
            default:
                return
            }
        default:
            return
        }
    }

}
