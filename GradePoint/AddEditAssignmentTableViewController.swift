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

    /// Delegate which will be notified of realm changes
    weak var listener: AssignmentChangesListener? = nil
    
    /// Realm database object
    let realm = DatabaseManager.shared.realm

    /// Outlet to the save button
    @IBOutlet weak var saveButton: UIBarButtonItem!

    /// The parent class which owns this Assignment, passed in via segue inside of ClassDetailTableViewController
    var parentClass: Class!
    
    /// The static cell content
    @IBOutlet weak var nameField: UIFloatingPromptTextField!
    @IBOutlet weak var datePickerField: UIPickerField!
    @IBOutlet weak var rubricPickerField: UIPickerField!
    @IBOutlet weak var scoreField: UIFloatingPromptTextField!

    /// The selected date from the date picker
    var selectedDate: Date = Date()
    
    /// The rubric selected from the rubric picker
    var selectedRubric: Rubric! = nil

    /// Assignment which will be edited if editing
    var assignmentForEdit: Assignment?

    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Field setup
        let attrsForPrompt: [NSAttributedStringKey: Any] = [.foregroundColor: ApplicationTheme.shared.secondaryTextColor(),
                                                            .font: UIFont.preferredFont(forTextStyle: .body)]
        self.nameField.titleText = "Assignment Name"
        self.nameField.titleTextSpacing = 8.0
        self.nameField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.nameField.attributedPlaceholder = NSAttributedString(string: "Assignment Name", attributes: attrsForPrompt)
        self.nameField.delegate = self
        self.nameField.autocapitalizationType = .words
        self.nameField.returnKeyType = .next
        self.nameField.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        
        // Custom date picker for `datePickerField`
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(self.datePickerChange(sender:)), for: .valueChanged)
        self.datePickerField.inputView = datePicker
        self.datePickerField.titleText = "Date"
        self.datePickerField.titleTextSpacing = 8.0
        self.datePickerField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.datePickerField.toolbar.barTintColor = ApplicationTheme.shared.highlightColor
        self.datePickerField.toolbar.tintColor = .white
        self.datePickerField.toolbarLabel.text = "Select a date"
        
        // Set up for rubric field
        self.rubricPickerField.titleText = "Rubric"
        self.rubricPickerField.titleTextSpacing = 8.0
        self.rubricPickerField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.rubricPickerField.toolbar.barTintColor = ApplicationTheme.shared.highlightColor
        self.rubricPickerField.toolbar.tintColor = .white
        self.rubricPickerField.toolbarLabel.text = "Select a rubric"
        
        // Set up for score field
        self.scoreField.titleText = "Score"
        self.scoreField.titleTextSpacing = 8.0
        self.scoreField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.scoreField.attributedPlaceholder = NSAttributedString(string: "Score", attributes: attrsForPrompt)
        self.scoreField.delegate = self
        self.scoreField.keyboardType = .decimalPad
        self.scoreField.fieldType = .percent
        self.scoreField.configuration = PercentConfiguration(allowsOver100: true, allowsFloatingPoint: true)
        self.scoreField.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: .editingChanged)
        // Add input accessory view to score field
        let fieldToolbar = UIToolbar()
        fieldToolbar.barStyle = .default
        fieldToolbar.items = [
            UIBarButtonItem(title: "Calculate", style: .done, target: self, action: #selector(self.assignmentNeedsCalculate)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.accessoryKeyboardDone))
        ]
        fieldToolbar.sizeToFit()
        fieldToolbar.barTintColor = ApplicationTheme.shared.highlightColor
        fieldToolbar.isTranslucent = false
        fieldToolbar.tintColor = .white
        self.scoreField.inputAccessoryView = fieldToolbar
        
        // Set picker field delegates/datasources
        self.datePickerField.pickerDelegate = self
        self.datePickerField.pickerDataSource = self
        self.rubricPickerField.pickerDelegate = self
        self.rubricPickerField.pickerDataSource = self
        
        // If editing, set default text for fields to stored values, otherwise use generic defaults
        if let assignment = assignmentForEdit {
            self.saveButton.isEnabled = true
            self.title = "Edit \(assignment.name)"
            self.nameField.text = assignment.name
            self.selectedRubric = assignment.rubric
            self.rubricPickerField.text = self.selectedRubric.name
            self.selectedDate = assignment.date
            self.datePickerField.text = formatDate(self.selectedDate)
            self.scoreField.text = "\(assignment.score)%"
        } else {
            self.saveButton.isEnabled = false
            self.selectedRubric = self.parentClass.rubrics.first
            self.rubricPickerField.text = self.selectedRubric.name
            self.selectedDate = Date()
            self.datePickerField.text = formatDate(self.selectedDate)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // UI Customization
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
        
        // Always toggle rubric and date picker fields title
        self.rubricPickerField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        self.datePickerField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        // If editing assignment, then we can go ahead and show titles for name and score fields, since they will have values
        if assignmentForEdit != nil {
            self.nameField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
            self.scoreField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        }
    }

    // MARK: - Table view

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.tintColor = ApplicationTheme.shared.tableViewHeaderColor
        header.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        header.textLabel?.textColor = ApplicationTheme.shared.tableViewHeaderTextColor
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Don't show any selection/color changes
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: self.nameField.becomeFirstResponder()
            case 1: self.datePickerField.becomeFirstResponder()
            case 2: self.rubricPickerField.becomeFirstResponder()
            default: return
            }
        } else {
            self.scoreField.becomeFirstResponder()
        }
    }

    // MARK: - Actions
    
    @IBAction func onCancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSave(_ sender: UIBarButtonItem) {
        
        guard nameField.text != nil, scoreField.text != nil else {
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
        if scoreText.last == "." {
            let last = scoreText.index(scoreText.endIndex, offsetBy: -1)
            scoreText.remove(at: last)
        }
        let score = Double(scoreText) ?? 0.0
        let oldRubric = assignmentForEdit?.rubric?.copy() as! Rubric

        // Write change to realm
        DatabaseManager.shared.write {
            assignmentForEdit?.name = name
            assignmentForEdit?.score = score
            assignmentForEdit?.date = self.selectedDate
            assignmentForEdit?.rubric = self.selectedRubric
        }
        
        self.dismiss(animated: true) {
            // Call deleggate if needed
            if oldRubric != self.selectedRubric {
                self.listener?.assignmentRubricWasUpdated(self.assignmentForEdit!, from: oldRubric, to: self.selectedRubric)
            }

            self.listener?.assignmentWasUpdated(self.assignmentForEdit!)
        }
    }
    
    /// Creates and saves a new assignment in Realm and dismisses view
    func saveNew() {
        // Can force unwrap because checked inside of onSave(_:)
        let name = nameField!.text!
        var scoreText = scoreField!.safeText
        if scoreText.last == "." {
            let last = scoreText.index(scoreText.endIndex, offsetBy: -1)
            scoreText.remove(at: last)
        }
        let score = Double(scoreText) ?? 0.0
    
        let newAssignment = Assignment(name: name, date: selectedDate, score: score, associatedRubric: self.selectedRubric)

        DatabaseManager.shared.write {
            parentClass.assignments.append(newAssignment)
        }

        self.dismiss(animated: true) {
            // Call listener
            self.listener?.assignmentWasCreated(newAssignment)
        }
    }
    
    @objc func datePickerChange(sender: UIDatePicker) {
        self.selectedDate = sender.date
        self.datePickerField.text = formatDate(sender.date)
    }
    
    @objc func assignmentNeedsCalculate(sender: UIBarButtonItem) {
        let controller = UICalculateViewController { [weak self] (percent) in
            self?.scoreField?.text = "\(percent)%"
            if let field = self?.scoreField { self?.textFieldChanged(field) }
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func accessoryKeyboardDone(sender: UIBarButtonItem) {
        self.scoreField.resignFirstResponder()
    }
    
    // MARK: Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - UITextField Delegate

extension AddEditAssignmentTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.nameField.resignFirstResponder()
            self.datePickerField.becomeFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let field = textField as? UIFloatingPromptTextField, field === scoreField {
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
        
        let nameValid = (nameF.text?.trimmingCharacters(in: CharacterSet.whitespaces))?.count ?? 0 > 0
        let scoreValid = (scoreF.text?.trimmingCharacters(in: CharacterSet.whitespaces))?.count ?? 0 > 0
        
        saveButton.isEnabled = scoreValid && nameValid
    }
}

// MARK: - UIPickerField Delegate & DataSource

extension AddEditAssignmentTableViewController: UIPickerFieldDataSource, UIPickerFieldDelegate {
    // NOTE: Since only using an actual rubric view for `rubricPickerField`, and not `datePickerField`, these
    // methods will only be used for the `rubricPickerField`
    
    func numberOfComponents(in field: UIPickerField) -> Int {
        return 1
    }
    
    func numberOfRows(in compononent: Int, for field: UIPickerField) -> Int {
        return self.parentClass.rubrics.count
    }
    
    func titleForRow(_ row: Int, in component: Int, for field: UIPickerField) -> String? {
        return self.parentClass.rubrics[row].name
    }
    
    func doneButtonTouched(for field: UIPickerField) {
        field.resignFirstResponder()
    }
    
    func didSelectPickerRow(_ row: Int, in component: Int, for field: UIPickerField) {
        // Set selected rubric to correct one
        self.selectedRubric = self.parentClass.rubrics[row]
    }
}


//extension AddEditAssignmentTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return parentClass.rubrics.count
//    }
//
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 25
//    }
//
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return pickerView.frame.width
//    }
//
//    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
//        let name = parentClass.rubrics[row].name
//        let title = NSMutableAttributedString(string: name)
//        title.addAttributes([.foregroundColor: UIColor.mainTextColor(),
//                             .font: UIFont.preferredFont(forTextStyle: .body)],
//                            range: (name as NSString).range(of: name))
//        return title
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return parentClass.rubrics[row].name
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        self.rubricPickerField.text = parentClass.rubrics[row].name
//    }
//}


