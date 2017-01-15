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
                                      UIRubricViewDelegate, UITextFieldDelegate, SemesterPickerDelegate, BlurAlertControllerDelegate {
    
    // MARK: - Properties
    
    // Realm database object
    let realm = try! Realm()
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    // Properties to handle the save button enabling and disabling
    var canSave = false {
        didSet {
            saveButton.isEnabled = canSave
        }
    }
    var rubricViewsAreValid = false {
        didSet {
            canSave = rubricViewsAreValid && nameFieldIsValid
        }
    }
    var nameFieldIsValid = false {
        didSet {
            canSave = nameFieldIsValid && rubricViewsAreValid
        }
    }
    
    /// The edit class object, if this is set it means were editing this class, updates UI with properties when set
    var editingClass: Class?
    
    var cellsCreatedForEdit = 0
    
    /// An array of rubric views that the controller will deal with (provided from the UIRubricTableViewCell)
    lazy var rubricViews = [UIRubricView]()
    
    /// The namefield which this controller handles, this field is part of the BasicInfoTableViewCell
    var nameField: UITextField!
    
    // Stored variable for cells, since I dont want to reuse them and lose any input user has put in
    var nameCell: TextInputTableViewCell?
    var semesterCell: GenericLabelTableViewCell?
    var semesterPickerCell: BasicInfoSemesterPickerTableViewCell?
    var rubricCells = [RubricTableViewCell]() {
        didSet {
            rubricViews.removeAll()
            for c in rubricCells {
                rubricViews.append(c.rubricView)
            }
        }
    }
    
    var numOfRubricViews = 1
    var isPresentingAlert: Bool?
    var isDatePickerVisible = false
    var semesterPicker: UISemesterPickerView?
    
    // The vars for the the finished class user is creating
    // These two are set using the picker view and get set in the pickerdelegate
    lazy var term: String = { Semester.terms[0] }()
    lazy var year: Int = { UISemesterPickerView.createArrayOfYears()[1] }() // Gets the 2nd year in the created array of years

    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable save button until fields are checked
        saveButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = UIColor.tableViewSeperator
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // createRandomClass()
        if let classObj = editingClass { updateUI(for: classObj) }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if let isP = self.isPresentingAlert, isP {
            // Keep the buttons disabled
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            // This will just be static 2, since only want Name and Term
            // Unless on iPhone screen size, then 3 because date picker is handled differently
            return 3
        case 1:
            // This will increase as user adds more rubrics (starts @ 1)
            return numOfRubricViews
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
                if let obj = editingClass { nameField.text = obj.name }
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
            if let obj = editingClass {
                if indexPath.row < obj.rubrics.count, cellsCreatedForEdit < obj.rubrics.count {
                    let rubricForRow = obj.rubrics[indexPath.row]
                    cell.rubricView.toEditState()
                    cell.rubricView.nameField.text = rubricForRow.name
                    cell.rubricView.weightField.text = "\(rubricForRow.weight)%"
                    cell.rubricView.nameField.resignFirstResponder()
                    cellsCreatedForEdit += 1
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
                toggleDatePicker()
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
    
    // MARK: - Rubric View Delegate
    
    func plusButtonTouched(inCell cell: RubricTableViewCell, forState state: UIRubricViewState) {
        switch state {
        case .collapsed:
            // Handle user cancelling that item
            handleCloseState(forCell: cell)
        case .open:
            // Handle user wanting to add a grade section
            handleOpenState(forCell: cell)
        case .edit:
            break
        }
    }
    
    func isRubricValidUpdated() {
        // Check edge case where user has only one rubric and no fields are set for it
        if rubricViews.count == 1 {
            let v = rubricViews[0]
            if v.nameField.text!.isEmpty || v.weightField.text!.isEmpty {
                rubricViewsAreValid = false
                return
            }
        }
        
        // Check if all rubric views are valid, update save button
        var validCount = 0
        for v in rubricViews {
            if v.isRubricValid { validCount += 1 }
        }
        rubricViewsAreValid = validCount == rubricViews.count
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
        // Check logic, i.e make sure rubrics add up to 100%
        var percent = 0.0
        var rubrics = [Rubric]()
        
        for i in 0..<rubricViews.count - 1 {
            guard let text = rubricViews[i].weightField.text?.replacingOccurrences(of: "%", with: "") else { // Removes the percent symbol, to all calculations
                return
            }
            
            if let p = Double(text) {
                if p <= 0 {
                    // Present an error dialog since we cannot save a percent of zero
                    let invalidRowSubMessage = "row \(i + 1)"
                    let message = "Zero percentage is invalid in " + invalidRowSubMessage
                    
                    // Attributes for the invalid row sub message
                    let attrs = [NSForegroundColorAttributeName: UIColor.sunsetOrange]
                    let rangeForSubMessage = (message as NSString).range(of: invalidRowSubMessage)
                    let attrString = NSMutableAttributedString(string: message)
                    attrString.addAttributes(attrs, range: rangeForSubMessage)
                    
                    presentAlert(withTitle: "Can't Save 💔", andMessage: attrString)
                    return
                }
                percent += p
                // Start creating the rubrics in order to optimize and not have to use another for loop when we validate
                let rView = rubricViews[i]
                let rubric = Rubric(withName: rView.nameField.text!, andWeight: p) // unwrapped because we cant be saving without text anyway
                rubrics.append(rubric)
            }
                
            else { fatalError("Unable to convert percent to a double") }
        }
        
        if percent == 100 {
            // Save the created class
            let semester = Semester(withTerm: self.term, andYear: self.year)
            let rubricList = List<Rubric>(rubrics)
            
            try! realm.write {
                if let classObj = self.editingClass {
                    classObj.name = self.nameField.text!
                    classObj.semester = semester
                    classObj.rubrics.removeAll()
                    classObj.rubrics.append(contentsOf: rubricList)
                } else {
                    let newClass = Class(withName: nameField.text!, inSemester: semester, withRubrics: rubricList)
                    realm.add(newClass)
                }
            }
            // Dismiss self
            self.dismiss(animated: true, completion: nil)
            
        } else {
            // Present error, since weights are not adding up to 100%
            let percentAttrs = [ NSForegroundColorAttributeName: UIColor.mutedText, NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
            let percentSubMessage = "\nCurrent total: \(percent)%"
            let message = "Weights must add up to 100%" + percentSubMessage
            let rangeForSubMessage = (message as NSString).range(of: percentSubMessage)
            
            // Add attributes to the percent submessage
            let attrString = NSMutableAttributedString(string: message)
            attrString.setAttributes(percentAttrs, range: rangeForSubMessage)
            
            presentAlert(withTitle: "Can't Save 💔", andMessage: attrString)
        }
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
        
        self.numOfRubricViews = obj.rubrics.count + 1
        self.tableView.reloadData()
        self.nameFieldIsValid = true
    }
    
    
    func handleOpenState(forCell cell: RubricTableViewCell) {
        
        // Lets create another one for the user incase they want to enter something
        let path = IndexPath(row: numOfRubricViews, section: 1)
        self.numOfRubricViews += 1
        
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: path, at: .bottom, animated: true)
        }
    }
    
    func handleCloseState(forCell cell: RubricTableViewCell) {
        guard let row = rubricCells.index(of: cell), numOfRubricViews > 1 else {
            fatalError("Could not find rubric view to delete")
        }
        
        self.numOfRubricViews -= 1
        
        // Disable the button, this fix issues where when spam touching button more than one view is created
        cell.rubricView.buttonGesture.isEnabled = false
        
        rubricCells.remove(at: row)
    
        let path = IndexPath(row: row, section: 1)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func toggleDatePicker() {
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
    
    func presentAlert(withTitle title: String, andMessage msg: NSAttributedString) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let alert = board.instantiateViewController(withIdentifier: "blurAlertController") as! BlurAlertController
        alert.view.frame = self.view.frame
        alert.alertTitle = title
        alert.alertMessage = msg
        alert.buttonText = "OK"
        alert.buttonColor = UIColor.sunsetOrange
        alert.delegate = self
        
        self.present(alert, animated: false, completion: {
            self.isPresentingAlert = true
            // Disable nav bar items while presenting
            DispatchQueue.main.async {
                self.navigationItem.leftBarButtonItem?.isEnabled = false
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        })
    }
    
    // MARK: Developer methods
    
    func createRandomClass() {
        self.nameField.text = "Test \(arc4random())"
        self.rubricViews.append(UIRubricView(frame: CGRect(x: 0, y: 0, width: 0, height: 0)))
        self.rubricViews[0].isRubricValid = true
        self.rubricViews[0].nameField.text = "Rubric \(arc4random())"
        self.rubricViews[0].weightField.text = "100"
        self.saveButton.isEnabled = true
    }
}