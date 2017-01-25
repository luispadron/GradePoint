//
//  AddEditClassTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class AddEditClassTableViewController: UITableViewController,
                                      UIRubricViewDelegate, UITextFieldDelegate, SemesterPickerDelegate {
    
    // MARK: - Properties
    
    /// Realm database object
    let realm = try! Realm()
    
    /// The save button in the navigation bar
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // Properties to handle the save button enabling and disabling
    var canSave = false { didSet { saveButton.isEnabled = canSave } }
    var rubricViewsAreValid = false { didSet { canSave = rubricViewsAreValid && nameFieldIsValid } }
    var nameFieldIsValid = false { didSet { canSave = nameFieldIsValid && rubricViewsAreValid }}
    
    /// The namefield which this controller handles, this field is part of the BasicInfoTableViewCell
    var nameField: UITextField!
    // Stored variable for cells, since I dont want to reuse them and lose any input user has put in
    var nameCell: TextInputTableViewCell?
    var semesterCell: GenericLabelTableViewCell?
    var semesterPickerCell: BasicInfoSemesterPickerTableViewCell?
    var rubricCells = [RubricTableViewCell]()
    var numOfRubricViewsToDisplay = 1
    
    var semesterPicker: UISemesterPickerView?
    var isDatePickerVisible = false
    var isPresentingAlert: Bool?
    
    // The vars for the the finished class user is creating
    // These two are set using the picker view and get set in the pickerdelegate
    lazy var term: String = { Semester.terms[0] }()
    // Gets the 2nd year in the created array of years, the second year is the current year
    lazy var year: Int = { UISemesterPickerView.createArrayOfYears()[1] }()

    // Variables that are in use when editing a class
    /// The edit class object, if this is set it means were editing this class, updates UI with properties when set
    var classObj: Class?
    /// A dictionary that associates a rubrics pk with its cell in the UI
    var editingRubrics = [String : RubricTableViewCell]()
    /// An array of rubric primary keys that will be deleted when save button is pressed
    var rubricsToDelete = [String]()
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change color of tableview seperators
        self.tableView.separatorColor = UIColor.tableViewSeperator
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Disable save button until fields are checked
        saveButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let classObj = classObj { updateUI(for: classObj) }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard let presentingAlert = self.isPresentingAlert, presentingAlert == true else {
            return
        }
        
        // Keep the buttons disabled
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }

    }
    
    // - MARK: - Table View Methods
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
            label.text = "Basic Information"
            return mainView
        case 1:
            label.text = "Grade Rubric"
            return mainView
        default:
            return nil
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // 3 static rows: name, semester, and semester picker
            return 3
        case 1:
            // This will increase as user adds more rubrics (starts @ 1)
            return numOfRubricViewsToDisplay
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 2 { return isDatePickerVisible ? 120 : 0 }
            return 44
        case 1:
            return 70
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If in first section use the basic info cell
        // Else use the rubric cell and cast
        
        // Add a clear selected view
        let emptyView = UIView()
        emptyView.backgroundColor = UIColor.darkBg
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: // Display the basic info name cell
                if let c = nameCell { return c }
                
                let cell = TextInputTableViewCell(style: .default, reuseIdentifier: nil)
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.inputLabel.text = "Name"
                cell.promptText = "Class Name"
                cell.inputField.delegate = self
                cell.inputField.addTarget(self, action: #selector(self.updateSaveButton), for: .editingChanged)
                nameField = cell.inputField
                nameCell = cell
                // If editing class is not nil, thus editing, then set the text for this field
                if let obj = classObj { nameField.text = obj.name }
                return cell
            case 1: // Display the basic info date picker cell
                if let c = semesterCell { return c }
                let cell = GenericLabelTableViewCell(style: .default, reuseIdentifier: nil)
                cell.leftLabel.text = "Date"
                cell.rightLabel.text = "\(Semester.terms[0]) \(UISemesterPickerView.createArrayOfYears()[1])"
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                semesterCell = cell
                return cell
            case 2:
                if let c = semesterPickerCell { return c }
                let cell = BasicInfoSemesterPickerTableViewCell(style: .default, reuseIdentifier: nil)
                cell.selectionStyle = .none
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.semesterPicker.delegate = self
                semesterPicker = cell.semesterPicker
                semesterPickerCell = cell
                return cell
            default:
                break
            }
            
        } else if indexPath.section == 1 {
            if indexPath.row < rubricCells.count { return rubricCells[indexPath.row] }
            let cell = RubricTableViewCell(style: .default, reuseIdentifier: nil)
            cell.selectedBackgroundView = emptyView
            cell.rubricView.delegate = self
            
            // If were editing the make sure to display the number of rubric views correctly and their fields
            if let obj = classObj {
                if indexPath.row < obj.rubrics.count, rubricCells.count < obj.rubrics.count {
                    let rubricForRow = obj.rubrics[indexPath.row]
                    cell.rubricView.toEditState() // Opens the rubric views and makes them editable
                    cell.rubricView.nameField.text = rubricForRow.name
                    cell.rubricView.weightField.text = "\(rubricForRow.weight)%"
                    cell.rubricView.nameField.resignFirstResponder()
                    // Add the association of pk to the displayed cell
                    editingRubrics[rubricForRow.id] = cell
                }
            }
            
            rubricCells.append(cell)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1:
                toggleSemesterPicker()
            default:
                break
            }
        }
    }
    
    // MARK: - Scroll View Delegates
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let field = nameField, field.isFirstResponder else {
            return
        }
        // Reisgn the name field and hide keyboard, this allows for better viewing
        field.resignFirstResponder()
    }
    
    // MARK: - Textfield delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameField { textField.resignFirstResponder() }
        updateSaveButton()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        updateSaveButton()
    }
    
    // MARK: - Rubric View Delegation
    
    func plusButtonTouched(inCell cell: RubricTableViewCell, withState state: UIRubricViewState?) {
        guard let `state` = state else {
            return
        }
        
        switch state {
        case .collapsed:
            // view was closed, open it
            handleOpenState(forCell: cell)
        case .open:
            // view was opened, close it
            handleCloseState(forCell: cell)
        }
    }
    
    func isRubricValidUpdated(forView view: UIRubricView) {
        // Initial case, only one rubric view, its valid but needs values so dont allow save
        if rubricCells.count == 1 {
            rubricViewsAreValid = false
        } else {
            var validCount = 0
            for (_, cell) in rubricCells.enumerated() {
                if cell.rubricView.isRubricValid { validCount += 1 }
                rubricViewsAreValid = validCount == rubricCells.count
            }
        }
    }
    
    
    func handleOpenState(forCell cell: RubricTableViewCell) {
        
        // Lets create another one for the user incase they want to enter something
        let path = IndexPath(row: numOfRubricViewsToDisplay, section: 1)
        self.numOfRubricViewsToDisplay += 1
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: path, at: .bottom, animated: true)
        }
    }
    
    func handleCloseState(forCell cell: RubricTableViewCell) {
        guard let row = rubricCells.index(of: cell), numOfRubricViewsToDisplay > 1 else {
            fatalError("Could not find rubric view to delete")
        }
        
        self.numOfRubricViewsToDisplay -= 1
        
        // Disable the button, this fix issues where when spam touching button more than one view is created
        cell.rubricView.buttonGesture.isEnabled = false
        
        rubricCells.remove(at: row)
        
        let path = IndexPath(row: row, section: 1)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
        }
        
        
        // If editing keep track of removed rubric
        if let _ = classObj {
            // Add the rubric to the rubricToDelete array
            let primaryKey = (editingRubrics as NSDictionary).allKeys(for: cell).first as! String
            rubricsToDelete.append(primaryKey)
        }
    }

    
    // MARK: - Date Input Delegate
    
    func pickerRowSelected(term: String, year: Int) {
        // User selected a date, lets update the UI
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GenericLabelTableViewCell
        cell.rightLabel.text = "\(term) \(year)"
        // Set the properties
        self.term = term
        self.year = year
    }
    
    // MARK: - Blur Alert Delegate
    
    func alertDidFinish() {
        self.isPresentingAlert = false
        DispatchQueue.main.async {
            // Reset the nav buttons
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    // - MARK: IBActions
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
        // Final check to make sure everything is ready
        guard isSaveReady() else {
            print("Not ready to save")
            return
        }
        // Save changes or save new class if not editing
        if let obj = classObj {
            saveChangesTo(obj)
        } else {
            saveNewClass()
        }
    }
    
    /// Saves a new class object to realm with all the data the user entered
    func saveNewClass() {
        // Want all rubric cells except the last one, since its always empty
        var cells = rubricCells
        cells.removeLast()
        
        // Rubrics to be created in realm
        var rubrics = [Rubric]()
        // Loop through the rubric cells and append rubrics to the rubrics array, can force unwrap since already checked for values
        for cell in cells {
            let view = cell.rubricView!
            // Get rubric info
            let rubricWeight = Double(view.weightField.text!.replacingOccurrences(of: "%", with: ""))!
            let rubricName = view.nameField.text!
            rubrics.append(Rubric(withName: rubricName, andWeight: rubricWeight))
        }
        
        // Create the semester
        let semester = Semester(withTerm: self.term, andYear: self.year)
        
        // Create the new class
        let newClass = Class(withName: self.nameField.text!, inSemester: semester, withRubrics: List<Rubric>(rubrics))
        
        try! realm.write {
            realm.add(newClass)
        }
    }
    
    /// Saves the edits the user made to the object
    func saveChangesTo(_ classObj: Class) {

    }
    
    // Checks the fields, makes sure percents add up to 100%, etc, if not presents alert
    func isSaveReady() -> Bool {
        // Want all rubric cells except the last one, since its always empty
        var cells = rubricCells
        cells.removeLast()
        
        // Keep track of total percent while looping
        var totalPercent = 0.0
        
        for cell in cells {
            let view = cell.rubricView
            guard let text = view?.weightField.text?.replacingOccurrences(of: "%", with: ""), let percent = Double(text) else {
                // Present dialog and return
                return false
            }
    
            if percent <= 0 {
                // Present alert warning user about zero percent
                print("Percent 0 error, not ready to save. Presenting alert")
                return false
            }
            
            totalPercent += percent
        }
        
        if totalPercent != 100 {
            print("Percent not equal to 100, not ready to save. Presenting alert")
            // Present alert telling user weights must add up to 100
            return false
        }
        
        return true
    }
    
    // - MARK: Helper Methods
    
    func updateUI(for obj: Class) {
        guard let semPicker = semesterPicker, let picker = semPicker.semesterPicker else {
            fatalError("Somehow picker views are not set??")
        }
        
        // Set the title and name field
        self.title = "Edit \(obj.name)"
        self.nameField.text = obj.name
        
        // Set the semester picker to correct values
        let iTerm = semPicker.terms.index(of: obj.semester!.term)!
        let iYear = semPicker.years.index(of: obj.semester!.year)!
        picker.selectRow(iTerm, inComponent: 0, animated: false)
        semPicker.pickerView(picker, didSelectRow: iTerm, inComponent: 0)
        picker.selectRow(iYear, inComponent: 1, animated: false)
        semPicker.pickerView(picker, didSelectRow: iYear, inComponent: 1)
        
        self.numOfRubricViewsToDisplay = obj.rubrics.count + 1
        self.tableView.reloadData()
        self.nameFieldIsValid = true
    }
    
    func toggleSemesterPicker() {
        guard let picker = semesterPicker, let cell = semesterCell else {
            print("Picker not available")
            return
        }
        
        // Show the date picker
        tableView.beginUpdates()
        isDatePickerVisible = !isDatePickerVisible
        tableView.endUpdates()
        picker.isHidden = !isDatePickerVisible
        picker.alpha = isDatePickerVisible ? 0.0 : 1.0
        // Animate the show
        UIView.animate(withDuration: 0.3) {
            cell.rightLabel.textColor = self.isDatePickerVisible ? UIColor.highlight : UIColor.lightText
            picker.alpha = self.isDatePickerVisible ? 1.0 : 0.0
        }
        
    }
    
    func updateSaveButton() {
        guard let text = nameField?.text else {
            nameFieldIsValid = false
            return
        }
        
        // Check for only whitespace in textfield
        let trimmed = text.trimmingCharacters(in: CharacterSet.whitespaces)
        nameFieldIsValid = trimmed.isEmpty ? false : true
    }
    
    /// Deletes all rubrics inside of the rubricsToDelete array
    func deleteRubrics() {
        
        for pk in rubricsToDelete {
            // Get the rubric from realm using the pk
            let rubric = realm.object(ofType: Rubric.self, forPrimaryKey: pk)!
            // Get the assignments associated with this rubric
            let assignments = realm.objects(Assignment.self).filter("associatedRubric = %@", rubric)
            // Write deletion to realm
            try! realm.write {
                realm.delete(rubric)
                realm.delete(assignments)
            }
        }
    }
    
    /// Presents an alert when provided the specified alertType
    private func present(alert type: AlertType, withTitle title: NSAttributedString, andMessage message: NSAttributedString) {
        // Closure which enables the nav buttons
        let enableNav = { [weak self] in
            self?.isPresentingAlert = false
            DispatchQueue.main.async {
                // Reset the nav buttons
                self?.navigationItem.leftBarButtonItem?.isEnabled = true
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
        
        // The alert controller
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200), title: title, message: message)
        
        switch type {
        case .message:
            let button = UIHandlerButton()
            button.setTitle("OK", for: .normal)
            button.backgroundColor = UIColor.lapisLazuli
            alert.addButton(button: button, handler: {
                enableNav()
            })
        case .deletion:
            break
        }
        
        // Present the alert
        alert.presentAlert(presentingViewController: self)
        
        // Make sure to disable the nav bar buttons when presenting alert
        self.isPresentingAlert = true
        DispatchQueue.main.async {
            // Reset the nav buttons
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
    }
}
