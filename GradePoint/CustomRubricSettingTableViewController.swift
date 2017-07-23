//
//  CustomRubricSettingTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class CustomRubricSettingTableViewController: UITableViewController {
    
    // MARK: Views
    @IBOutlet var weightFields: Array<UISafeTextField>!
    @IBOutlet weak var fieldToggle: UISwitch!
    
    /// The rows which will contain any + or - fields
    let plusRows = [0, 2, 3, 5, 6,  8, 9, 11]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .never
        } 
        
        // TableView customization
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                                 target: self,
                                                                 action: #selector(self.onSaveTapped))
        
        
        let scale = DatabaseManager.shared.realm.objects(GPAScale.self)[0]

        // See if field toggle has been disabled or enabled previously
        self.fieldToggle.isOn = scale.scaleType.rawValue == 1 ? true : false
        
        // Customize the fields and initialize them to their stored values
        var relatedIndex = 0 // The index related the GPAScale rubrics
        for (index, field) in weightFields.enumerated() {
            let config = NumberConfiguration(allowsSignedNumbers: false, range: 0...99)
            field.configuration = config
            field.fieldType = .number
            field.keyboardType = .numbersAndPunctuation
            field.delegate = self
            field.returnKeyType = .done
            field.font = UIFont.systemFont(ofSize: 18)
            field.tintColor = UIColor.highlight
            field.textColor = UIColor.highlight
            // Load the stored values as the text and place holders
            if !self.fieldToggle.isOn && plusRows.contains(index) {
                field.attributedPlaceholder = NSAttributedString(string: "Points",
                                                            attributes: [.font: UIFont.systemFont(ofSize: 18),
                                                                         .foregroundColor: UIColor.secondaryTextColor()])
                relatedIndex -= 1
            } else {
                field.text = "\(scale.gpaRubrics[relatedIndex].gradePoints)"
                field.attributedPlaceholder = NSAttributedString(string: "\(scale.gpaRubrics[relatedIndex].gradePoints)",
                                                            attributes: [.font: UIFont.systemFont(ofSize: 18),
                                                                         .foregroundColor: UIColor.secondaryTextColor()])
            }
            relatedIndex += 1
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && plusRows.contains(indexPath.row) && !fieldToggle.isOn {
            return 0
        }
        
        return 60
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 1 else { return 1 }
        return 13
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.selectionStyle = .none
        for view in cell.contentView.subviews {
            if let label = view as? UILabel {
                label.textColor = UIColor.mainTextColor()
            } else {
                if let label = view.subviews.first as? UILabel {
                    label.textColor = UIColor.secondaryTextColor()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        return "Grade Rubric"
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = UIColor.tableViewHeader
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.textColor = UIColor.tableViewHeaderText
    }

    // MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // Toggle the cells
        self.tableView.reloadData()
    }
    
    @objc func onSaveTapped() {
        // Collect all the user entered data
        var points = [Double]()
        for (index, field) in weightFields.enumerated() {
            // Skip over plus fields if they're disabled
            if !fieldToggle.isOn && plusRows.contains(index) { continue }
            
            if field.safeText.isEmpty || Double(field.safeText) == nil {
                self.presentErrorAlert(title: "Unable To Save", message: "Please make sure all fields are filled out")
                return
            }
            
            points.append(Double(field.safeText)!.roundedUpTo(2))
        }
        
        // Warn the user that this cant be undone
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200),
                                        title: NSAttributedString(string: "Save Grade Rubric"),
                                        message: NSAttributedString(string: "Are you sure you want to save?\nThis can't be undone"))
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.setTitleColor(.white, for: .normal)
        cancel.backgroundColor = UIColor.info
        
        let save = UIButton()
        save.setTitle("Save", for: .normal)
        save.setTitleColor(.white, for: .normal)
        save.backgroundColor = UIColor.warning
        
        alert.addButton(button: cancel, handler: nil)
        alert.addButton(button: save) { [weak self] in
            self?.saveChanges(withPoints: points)
        }
        
        alert.presentAlert(presentingViewController: self)
    }
    
    private func saveChanges(withPoints points: [Double]) {
        
        // Save changes to the GPAScale
        let type = self.fieldToggle.isOn ? GPAScaleType.plusScale : GPAScaleType.nonPlusScale
        if !GPAScale.overwriteScale(type: type, gradePoints: points) {
            self.presentErrorAlert(title: "Unable To Save",
                                   message: "Something went wrong when saving, please verify that all information has been entered correctly.")
        } else {
            // Dismiss
            self.navigationController?.popToRootViewController(animated: true)
        }
    }

}

extension CustomRubricSettingTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UISafeTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
}

