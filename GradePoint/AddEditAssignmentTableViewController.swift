//
//  AddEditAssignmentTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 12/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class AddEditAssignmentTableViewController: UITableViewController, UITextFieldDelegate,
                                            UIPickerViewDelegate, UIPickerViewDataSource {

    // MARK: - Properties
    
    // Realm database object
    let realm = try! Realm()
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var parentClass: Class!
    
    var dateLabel: UILabel!
    var rubricLabel: UILabel!
    
    var datePickerIsVisible = false
    var rubricPickerIsVisible = false
    
    var nameField: UITextField?
    var scoreField: UITextField?
    
    var selectedDate: Date = Date()
    
    var delegate: AddEditAssignmentViewDelegate?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        saveButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = UIColor.tableViewSeperator
    }
    

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 5
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 2:
                return datePickerIsVisible ? 120 : 0
            case 4:
                return rubricPickerIsVisible ? 80 : 0
            default:
                return 44
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 44))
        mainView.backgroundColor = UIColor.tableViewHeader
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.tableViewHeader
        mainView.addSubview(label)
        
        switch section {
        case 0:
            label.text = "Basic Info"
            return mainView
        case 1:
            label.text = "Assignment Score"
            return mainView
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = TextInputTableViewCell(style: .default, reuseIdentifier: nil)
                cell.inputLabel.text = "Name"
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.promptText = "Assignment Name"
                cell.inputField.delegate = self
                cell.inputField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                self.nameField = cell.inputField
                return cell
            case 1:
                let cell = GenericLabelTableViewCell(style: .default, reuseIdentifier: nil)
                cell.leftLabel.text = "Date"
                // Init the right label 'date label', set text to todays date
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                cell.rightLabel.text = formatter.string(from: Date())
                self.dateLabel = cell.rightLabel
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                return cell
            case 2:
                let cell = BasicInfoDatePickerTableViewCell(style: .default, reuseIdentifier: nil)
                // Add action from date picker
                cell.datePicker.addTarget(self, action: #selector(self.datePickerChange), for: .valueChanged)
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                return cell
            case 3:
                let cell = GenericLabelTableViewCell(style: .default, reuseIdentifier: nil)
                cell.leftLabel.text = "Rubric"
                cell.rightLabel.text = self.parentClass.rubrics[0].name
                self.rubricLabel = cell.rightLabel
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                return cell
            case 4:
                let cell = BasicInfoRubricPickerTableViewCell(style: .default, reuseIdentifier: nil)
                cell.rubricPicker.delegate = self
                cell.rubricPicker.dataSource = self
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                return cell
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                let cell = TextInputTableViewCell(style: .default, reuseIdentifier: nil)
                cell.inputField = UIPercentField()
                (cell.inputField as! UIPercentField).allowsAllPercents = true
                cell.inputLabel.text = "Score"
                cell.promptText = "Assignment Score"
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.inputField.delegate = self
                cell.inputField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                self.scoreField = cell.inputField
                return cell
            default:
                break
            }
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1: // Date section selected, show or hide datePicker accordingly
            togglePicker()
        case 3:
            togglePicker()
        default:
            return
        }
    }
    
    // MARK: - UIPickerView Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parentClass.rubrics.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 25
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.width
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let name = parentClass.rubrics[row].name
        let title = NSMutableAttributedString(string: name)
        title.addAttributes([NSForegroundColorAttributeName: UIColor.lightText,
                             NSFontAttributeName: UIFont.systemFont(ofSize: 20)],
                            range: (name as NSString).range(of: name))
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return parentClass.rubrics[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.rubricLabel.text = parentClass.rubrics[row].name
    }
    
    // MARK: - UITextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let field = textField as? UIPercentField, field === scoreField {
            return field.shouldChangeText(replacementText: string)
        }
        
        return true
    }
    
    func textFieldChanged(_ textField: UITextField) {
        guard let nameF = nameField, let scoreF = scoreField else {
            print("Error couldn't get instances of textfields")
            saveButton.isEnabled = false
            return
        }
        
        let nameValid = (nameF.text?.trimmingCharacters(in: CharacterSet.whitespaces))?.characters.count ?? 0 > 0
        let scoreValid = (scoreF.text?.trimmingCharacters(in: CharacterSet.whitespaces))?.characters.count ?? 0 > 0
        
        saveButton.isEnabled = scoreValid && nameValid
    }

    // MARK: - Actions
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        // Save the associated assignment to realm
        guard let nText = nameField?.text, var sText = scoreField?.text?.replacingOccurrences(of: "%", with: ""),
              let rubricPicker = (tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as?
                                    BasicInfoRubricPickerTableViewCell)?.rubricPicker
        else {
            fatalError("Could not save because guard failed")
        }
        
        // Check the score text and make sure that if there is a '.' it doesnt end in it, if it does remove it
        if sText.characters.last == "." { sText = sText.substring(to: sText.index(before: sText.endIndex)) }
        let score = Double(sText)!
        let rubric = parentClass.rubrics[rubricPicker.selectedRow(inComponent: 0)]
        let newAssignment = Assignment(name: nText, date: selectedDate, score: score, associatedRubric: rubric)
        
        try! realm.write {
            parentClass.assignments.append(newAssignment)
        }
        
        self.dismiss(animated: true) {
            self.delegate?.viewDidFinishAddingEditing(assignment: newAssignment)
        }
    }
    
    func datePickerChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        self.selectedDate = sender.date
        self.dateLabel.text = formatter.string(from: sender.date)
    }
    
    // MARK: Helper Methods
    
    func togglePicker() {
        guard let selectedPath = tableView.indexPathForSelectedRow else {
            print("No row selected?")
            return
        }

        switch selectedPath.row {
        case 1:
            let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! BasicInfoDatePickerTableViewCell
            // Show the date picker
            tableView.beginUpdates()
            datePickerIsVisible = !datePickerIsVisible
            tableView.endUpdates()
            cell.datePicker.isHidden = !datePickerIsVisible
            cell.datePicker.alpha = datePickerIsVisible ? 0.0 : 1.0
            // Animate the show
            UIView.animate(withDuration: 0.3) {
                self.dateLabel.textColor = self.datePickerIsVisible ? UIColor.highlight : UIColor.lightText
                cell.datePicker.alpha = self.datePickerIsVisible ? 1.0 : 0.0
            }
        case 3:
            let cell = tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! BasicInfoRubricPickerTableViewCell
            // Show the rubric picker
            tableView.beginUpdates()
            rubricPickerIsVisible = !rubricPickerIsVisible
            tableView.endUpdates()
            cell.rubricPicker.isHidden = !rubricPickerIsVisible
            cell.rubricPicker.alpha = rubricPickerIsVisible ? 0.0 : 1.0
            // Animate the show
            UIView.animate(withDuration: 0.3) {
                self.rubricLabel.textColor = self.rubricPickerIsVisible ? UIColor.highlight : UIColor.lightText
                cell.rubricPicker.alpha = self.rubricPickerIsVisible ? 1.0 : 0.0
            }
        default:
            return
        }
    }



}
