//
//  AddEditAssignmentTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 12/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class AddEditAssignmentTableViewController: UITableViewController {

    // MARK: - Properties
    
    /// Realm database object
    let realm = DatabaseManager.shared.realm

    /// Outlet to the save button
    @IBOutlet weak var saveButton: UIBarButtonItem!

    /// The parent class which owns this Assignment, passed in via segue inside of ClassDetailTableViewController
    var parentClass: Class!
    
    /// The static cells, resused in cellForRow
    var nameCell: UITableViewCell?
    var dateLabelCell: UITableViewCell?
    var dateCell: UITableViewCell?
    var rubricLabelCell: UITableViewCell?
    var rubricCell: UITableViewCell?
    var scoreCell: UITableViewCell?
    
    /// The date label, which displays the value picked from the date picker
    var dateLabel: UILabel!

    /// The rubric label, which displays the value picked from the rubric picker
    var rubricLabel: UILabel!

    /// Boolean for determining whether datePicker is visible or not
    var datePickerIsVisible = false

    /// Boolean for determining whether rubricPicker is visible or not
    var rubricPickerIsVisible = false

    /// The name field textfield
    var nameField: UITextField?

    /// The score field textfield
    var scoreField: UISafeTextField?

    /// The selected date from the date picker
    var selectedDate: Date = Date()

    /// Assignment which will be edited if editing
    var assignmentForEdit: Assignment?

    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)

        saveButton.isEnabled = assignmentForEdit != nil ? true : false
        // If editing, set the title
        if let assignment = assignmentForEdit { self.title = "Edit \(assignment.name)" }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = UIColor.tableViewSeperator
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // If editing, select the correct date and rubric
        if let assignment = assignmentForEdit { updatePickers(for: assignment) }
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

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Basic Information"
        case 1:
            return "Assignment Score"
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 2:
                return datePickerIsVisible ? 120 : 0
            case 4:
                return rubricPickerIsVisible ? 120 : 0
            default:
                return 60
            }
        }
        
        return 60
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if let cachedCell = self.nameCell { return cachedCell }
                let cell = TextInputTableViewCell(style: .default, reuseIdentifier: nil)
                cell.inputLabel.text = "Name"
                cell.selectionStyle = .none
                cell.promptText = "Assignment Name"
                cell.inputField.delegate = self
                cell.inputField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                if let assignment = assignmentForEdit { cell.inputField.text = assignment.name }
                self.nameField = cell.inputField
                self.nameCell = cell
                return cell
            case 1:
                if let cachedCell = self.dateLabelCell { return cachedCell }
                let cell = GenericLabelTableViewCell(style: .default, reuseIdentifier: nil)
                cell.leftLabel.text = "Date"
                // Init the right label 'date label', set text to todays date
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                if let assignment = assignmentForEdit { cell.rightLabel.text = formatter.string(from: assignment.date) }
                else { cell.rightLabel.text = formatter.string(from: Date()) }
                self.dateLabel = cell.rightLabel
                cell.selectionStyle = .none
                self.dateLabelCell = cell
                return cell
            case 2:
                if let cachedCell = self.dateCell { return cachedCell }
                let cell = BasicInfoDatePickerTableViewCell(style: .default, reuseIdentifier: nil)
                // Add action from date picker
                cell.datePicker.addTarget(self, action: #selector(self.datePickerChange), for: .valueChanged)
                cell.selectionStyle = .none
                self.dateCell = cell
                return cell
            case 3:
                if let cachedCell = self.rubricLabelCell { return cachedCell }
                let cell = GenericLabelTableViewCell(style: .default, reuseIdentifier: nil)
                cell.leftLabel.text = "Rubric"
                if let assignment = assignmentForEdit { cell.rightLabel.text = assignment.rubric!.name }
                else { cell.rightLabel.text = self.parentClass.rubrics[0].name }
                self.rubricLabel = cell.rightLabel
                cell.selectionStyle = .none
                self.rubricLabelCell = cell
                return cell
            case 4:
                if let cachedCell = self.rubricCell { return cachedCell }
                let cell = BasicInfoRubricPickerTableViewCell(style: .default, reuseIdentifier: nil)
                cell.rubricPicker.delegate = self
                cell.rubricPicker.dataSource = self
                cell.selectionStyle = .none
                self.rubricCell = cell
                return cell
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                if let cachedCell = self.scoreCell { return cachedCell }
                let cell = TextInputTableViewCell(style: .default, reuseIdentifier: nil)
                let config = PercentConfiguration(allowsOver100: true, allowsFloatingPoint: true)
                let textField = UISafeTextField(frame: .zero, fieldType: .percent, configuration: config)
                cell.inputField = textField
                // Add input accessory view to keyboard
                let inputFieldToolbar = UIToolbar()
                inputFieldToolbar.barStyle = .default
                inputFieldToolbar.items = [
                    UIBarButtonItem(title: "Calculate", style: .done, target: self, action: #selector(self.assignmentNeedsCalculate)),
                    UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                    UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.accesoryKeyboardDone))
                ]
                inputFieldToolbar.sizeToFit()
                inputFieldToolbar.barTintColor = UIColor.lightBackground
                inputFieldToolbar.isTranslucent = false
                cell.inputField.inputAccessoryView = inputFieldToolbar
                cell.inputLabel.text = "Score"
                cell.promptText = "Assignment Score"
                cell.selectionStyle = .none
                cell.inputField.delegate = self
                cell.inputField.addTarget(self, action: #selector(self.textFieldChanged), for: .editingChanged)
                if let assignment = assignmentForEdit { cell.inputField.text = "\(assignment.score.roundedUpTo(2))%" }
                self.scoreField = cell.inputField as? UISafeTextField
                self.scoreCell = cell
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
    
    // MARK: - ScrollView Methods
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Resign name field on scroll
        let nameField = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextInputTableViewCell)?.inputField
        nameField?.resignFirstResponder()
    }

    // MARK: - Actions
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        
        guard let _ = nameField?.text, let text = scoreField?.safeText, text.characters.count > 0,
            let _ = (tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? BasicInfoRubricPickerTableViewCell)?.rubricPicker else {
                self.presentErrorAlert(title: "Error Saving", message: "Unable to save this assignment, due to an unknown error.")
                return
        }
        
        if let _ = assignmentForEdit { saveChanges() }
        else { saveNew() }
    }
    
    /// Updates assignment in Realm and dismisses view
    func saveChanges() {
        // Can force unwrap here since we checked in the guard of onSave(_:)
        let name = nameField!.text!
        var scoreText = scoreField!.safeText
        if scoreText.characters.last == "." {
            let last = scoreText.index(scoreText.endIndex, offsetBy: -1)
            scoreText.remove(at: last)
        }
        let score = Double(scoreText) ?? 0.0
        let indexOfRubric = (tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! BasicInfoRubricPickerTableViewCell).rubricPicker.selectedRow(inComponent: 0)
        let rubric = parentClass!.rubrics[indexOfRubric]
        
        // Write change to realm
        DatabaseManager.shared.write {
            assignmentForEdit?.name = name
            assignmentForEdit?.score = score
            assignmentForEdit?.date = selectedDate
            assignmentForEdit?.rubric = rubric
        }
        
        self.dismiss(animated: true)
    }
    
    /// Creates and saves a new assignment in Realm and dismisses view
    func saveNew() {
        // Can force unwrap because checked inside of onSave(_:)
        let name = nameField!.text!
        var scoreText = scoreField!.safeText
        if scoreText.characters.last == "." {
            let last = scoreText.index(scoreText.endIndex, offsetBy: -1)
            scoreText.remove(at: last)
        }
        let score = Double(scoreText) ?? 0.0
        let indexOfRubric = (tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as! BasicInfoRubricPickerTableViewCell).rubricPicker.selectedRow(inComponent: 0)
        let rubric = parentClass!.rubrics[indexOfRubric]
        
        let newAssignment = Assignment(name: name, date: selectedDate, score: score, associatedRubric: rubric)

        DatabaseManager.shared.write {
            parentClass.assignments.append(newAssignment)
        }

        self.dismiss(animated: true)
    }
    
    @objc func datePickerChange(sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        self.selectedDate = sender.date
        self.dateLabel.text = formatter.string(from: sender.date)
    }
    
    @objc func assignmentNeedsCalculate(sender: UIBarButtonItem) {
        let controller = UICalculateViewController { [weak self] (percent) in
            self?.scoreField?.text = "\(percent)%"
            if let field = self?.scoreField { self?.textFieldChanged(field) }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    // MARK: Helper Methods
    
    @objc func accesoryKeyboardDone() {
        guard let textField = (tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? TextInputTableViewCell)?.inputField else {
            print("Couldn't get keyboard to when user clicked on done, method: accesoryKeyboardDone")
            return
        }
        
        textField.resignFirstResponder()
    }
    
    /// Updates the pickers to the appropriate values for the assignment being edited
    func updatePickers(for assignment: Assignment) {
        guard let datePicker = (tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? BasicInfoDatePickerTableViewCell)?.datePicker,
            let rubricPicker = (tableView.cellForRow(at: IndexPath(row: 4, section: 0)) as? BasicInfoRubricPickerTableViewCell)?.rubricPicker else {
                print("WARNING: Unable to get pickers for update")
                return
        }
        
        // Update date picker
        datePicker.setDate(assignment.date, animated: false)
        // Update rubric picker
        if let indexOfRubric = parentClass.rubrics.index(of: assignment.rubric!) {
            rubricPicker.selectRow(indexOfRubric, inComponent: 0, animated: false)
            self.pickerView(rubricPicker, didSelectRow: indexOfRubric, inComponent: 0)
        }
    }
    
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
                self.dateLabel.textColor = self.datePickerIsVisible ? UIColor.highlight : UIColor.mainTextColor()
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
                self.rubricLabel.textColor = self.rubricPickerIsVisible ? UIColor.highlight : UIColor.mainTextColor()
                cell.rubricPicker.alpha = self.rubricPickerIsVisible ? 1.0 : 0.0
            }
        default:
            return
        }
    }
}

// MARK: - UITextField Delegate

extension AddEditAssignmentTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let field = textField as? UISafeTextField, field === scoreField {
            return field.shouldChangeTextAfterCheck(text: string)
        }
        
        return true
    }
    
    @objc func textFieldChanged(_ textField: UITextField) {
        guard let nameF = nameField, let scoreF = scoreField else {
            print("Error couldn't get instances of textfields")
            saveButton.isEnabled = false
            return
        }
        
        let nameValid = (nameF.text?.trimmingCharacters(in: CharacterSet.whitespaces))?.characters.count ?? 0 > 0
        let scoreValid = (scoreF.text?.trimmingCharacters(in: CharacterSet.whitespaces))?.characters.count ?? 0 > 0
        
        saveButton.isEnabled = scoreValid && nameValid
    }
}

// MARK: - UIPickerView Delegate & UIPickerView Data Source

extension AddEditAssignmentTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        title.addAttributes([.foregroundColor: UIColor.mainTextColor(),
                             .font: UIFont.preferredFont(forTextStyle: .body)],
                            range: (name as NSString).range(of: name))
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return parentClass.rubrics[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.rubricLabel.text = parentClass.rubrics[row].name
    }
}


