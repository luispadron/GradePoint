//
//  CustomRubricSettingTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/29/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class CustomRubricSettingTableViewController: UITableViewController {
    
    // MARK: Views
    @IBOutlet var weightFields: Array<UISafeTextField>?
    
    /// The rows which will contain any + or - fields
    let plusRows = [0, 2, 3, 5, 6,  8, 9, 11]

    var isPlusEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TableView customization
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = UIColor.tableViewSeperator
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.onSaveTapped))
        // Customize the fields
        for field in weightFields! {
            let config = NumberConfiguration(allowsSignedNumbers: false, range: 0...99)
            field.configuration = config
            field.fieldType = .number
            field.keyboardType = .numbersAndPunctuation
            field.delegate = self
            field.returnKeyType = .done
            field.attributedPlaceholder = NSAttributedString(string: "Test", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.mutedText])
            field.font = UIFont.systemFont(ofSize: 18)
            field.tintColor = UIColor.highlight
            field.textColor = UIColor.white
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - TableView Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && plusRows.contains(indexPath.row) && !isPlusEnabled {
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
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 30))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        if section == 1 { label.text = "Grade Rubric" }
        mainView.addSubview(label)
        
        return mainView
    }
    
    // MARK: Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // Toggle the cells
        self.isPlusEnabled = sender.isOn
        self.tableView.reloadData()
    }
    
    func onSaveTapped() {
        self.navigationController?.popToRootViewController(animated: true)
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

