//
//  AddEditClassTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class AddEditClassTableViewController: UITableViewController {
    
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
    /// Boolean to determine if we have already loaded the rubrics that are being edited, if this is true, we dont want to load them again 
    var needsToLoadCellsForEdit = true
    
    /// The delegate for this view, will be notified when finished editing or creating new class
    weak var delegate: AddEditClassViewDelegate?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Change color of tableview seperators
        self.tableView.separatorColor = UIColor.tableViewSeperator
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        // Disable save button until fields are checked
        saveButton.isEnabled = false
        
        if let obj = classObj {
            self.title = "Edit " + obj.name
            self.numOfRubricViewsToDisplay = obj.rubrics.count + 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // If editing update the semester picker and select the saved values
        if let obj = classObj { updateSemesterPicker(for: obj) }
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard let presentingAlert = self.isPresentingAlert, presentingAlert == true else {
            self.navigationItem.leftBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.isEnabled = self.canSave
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
                if let obj = classObj {
                    nameField.text = obj.name
                    self.nameFieldIsValid = true
                }
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
            // Only do this for the inital load
            if let obj = classObj, needsToLoadCellsForEdit {
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
            
            // Add an accesory button the rubrics views weight field to calculate a percentage
            // Add an input accessory view which will display done
            let weightFieldToolBar = UIToolbar()
            weightFieldToolBar.barStyle = .default
            weightFieldToolBar.items = [
                UIBarButtonItem(title: "Calculate", style: .done, target: self, action: #selector(self.rubricNeedsCalculate(sender:))),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.rubricWeightFieldDone(sender:)))
            ]
            weightFieldToolBar.sizeToFit()
            weightFieldToolBar.barTintColor = UIColor.darkBg
            weightFieldToolBar.isTranslucent = false
            cell.rubricView.weightField.inputAccessoryView = weightFieldToolBar
            
            rubricCells.append(cell)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let obj = classObj, indexPath.section == 1, needsToLoadCellsForEdit, indexPath.row >= obj.rubrics.count else {
            return
        }
        
        self.needsToLoadCellsForEdit = false
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
            let rubricWeight = Double(view.weightField.safeText)!
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
        
        
        // Dismiss controller 
        self.dismiss(animated: true) { [weak self] in
            // Call the delegate tell it were done creating this class
            self?.delegate?.didFinishCreating(newClass: newClass)
        }
    }
    
    /// Saves the edits the user made to the object
    func saveChangesTo(_ classObj: Class) {
        // Lets save the changes made to the Class object, again can force unwrap since already checked for values
        let name = self.nameField.text!
        
        // Write name and semester changes to realm
        try! realm.write {
            classObj.name = name
            classObj.semester?.term = self.term
            classObj.semester?.year = self.year
        }
        
        // Remove rubrics from class obj that were deleted by the user
        self.deleteRubrics()
        // Loop through the rubrics array and make those changes finally
        for (pk, cell) in editingRubrics {
            let savedRubric = realm.object(ofType: Rubric.self, forPrimaryKey: pk)!
            try! realm.write {
                savedRubric.name = cell.rubricView.nameField.text!
                savedRubric.weight = Double(cell.rubricView.weightField.safeText)!
            }
            // Finally remove this from the list of rubricCells since we don't need this info for this edited cell, only for new now
            if let index = rubricCells.index(of: cell) { rubricCells.remove(at: index) }
        }
        
        // Add any remaining rubric views values to a new rubric
        var newRubricCells = rubricCells
        // Remove last because thats the empty one that's always there
        newRubricCells.removeLast()
        for cell in newRubricCells {
            let name = cell.rubricView.nameField.text!
            let weight = Double(cell.rubricView.weightField.safeText)!
            let newRubric = Rubric(withName: name, andWeight: weight)
            try! realm.write {
                classObj.rubrics.append(newRubric)
            }
        }
        
        // Dismiss controller
        self.dismiss(animated: true) { [weak self] in
            // Call the delegate method, tell it were done updating the class
            self?.delegate?.didFinishUpdating(classObj: classObj)
        }
    }
    
    
    // Checks the fields, makes sure percents add up to 100%, etc, if not presents alert
    func isSaveReady() -> Bool {
        // Want all rubric cells except the last one, since its always empty
        var cells = rubricCells
        cells.removeLast()
        
        // Keep track of total percent while looping
        var totalPercent: Double = 0.0
        
        for (index, cell) in cells.enumerated() {
            let view = cell.rubricView
            guard let text = view?.weightField.safeText, let percent = Double(text) else {
                presentErrorAlert(title: "Unable to save", message: "Some data is incorrect and cannot save, please check values and try again")
                return false
            }
    
            if percent <= 0 {
                // Present alert warning user about zero percent
                // Construct title
                let title = NSAttributedString(string: "Can't Save 💔", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
                // Construct attributed message
                let invalidRowSubmessage = "row \(index + 1)"
                let attrsForSub = [NSForegroundColorAttributeName : UIColor.sunsetOrange, NSFontAttributeName : UIFont.systemFont(ofSize: 15)]
                let attrsForMessage = [NSForegroundColorAttributeName : UIColor.mutedText, NSFontAttributeName : UIFont.systemFont(ofSize: 15)]
                let message = "Zero percentage is invalid in " + invalidRowSubmessage
                let messageAttributed = NSMutableAttributedString(string: message, attributes: attrsForMessage)
                messageAttributed.addAttributes(attrsForSub, range: (message as NSString).range(of: invalidRowSubmessage))
                
                self.present(alert: .message, withTitle: title, andMessage: messageAttributed)
                return false
            }
            
            totalPercent += percent
        }
        
        if round(totalPercent) != 100 {
            print("Percent not equal to 100, not ready to save. Presenting alert")
            // Present alert telling user weights must add up to 100
            // Construct title
            let title = NSAttributedString(string: "Can't Save 💔", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
            // Construct the message
            let percentSubMessage = "\nCurrent total: \(totalPercent)%"
            let message = "Weights must add up to 100%" + percentSubMessage
            let attrsForMessage = [NSForegroundColorAttributeName : UIColor.mutedText, NSFontAttributeName : UIFont.systemFont(ofSize: 15)]
            let messageAttributed = NSMutableAttributedString(string: message, attributes: attrsForMessage)
        
            self.present(alert: .message, withTitle: title, andMessage: messageAttributed)
            return false
        }
        
        return true
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
                for assignment in assignments {
                    realm.delete(assignment)
                }
                
                realm.delete(rubric)
            }
            
            // Remove this rubric from the editing rubrics array
            editingRubrics.removeValue(forKey: pk)
        }
        // Done deleting no longer need this
        rubricsToDelete.removeAll()
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
    
    /// Presents an alert when provided the specified alertType
    func present(alert type: AlertType, withTitle title: NSAttributedString, andMessage message: NSAttributedString, options: [Any]? = nil) {
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
            // Add the ok button
            let button = UIButton()
            button.setTitle("OK", for: .normal)
            button.backgroundColor = UIColor.lapisLazuli
            alert.addButton(button: button, handler: {
                enableNav() // enable the nav
            })
            
        case .deletion:
            // Set alert type
            alert.alertFeedbackType = .warning
            // Create and add the cancel button
            let cancel = UIButton()
            cancel.setTitle("Cancel", for: .normal)
            cancel.backgroundColor = UIColor.lapisLazuli
            alert.addButton(button: cancel, handler: { 
                enableNav() //enable the nav
            })
            
            // Create and add the delete button
            let delete = UIButton()
            delete.setTitle("Delete", for: .normal)
            delete.backgroundColor = UIColor.sunsetOrange
            alert.addButton(button: delete, handler: { [weak self] in
                enableNav()
                guard let strongSelf = self else {
                    print("Unable to get self inside delete handler, class: \(AddEditClassTableViewController.self)")
                    return
                }
                
                // If calling this method with .delete then we have been sent the cell and pk in the options
                if let opts = options, opts.count > 0, let cell = opts[0] as? RubricTableViewCell, let pk = opts[1] as? String {
                    // Add this rubrics pk to the rubricsToDelete array, will be deleted when saving
                    strongSelf.rubricsToDelete.append(pk)
                    // Don't present the alert asking if they wish to delte again but close the view and make it look delete
                    strongSelf.handleCloseState(forCell: cell, shouldPresentAlert: false)
                } else {
                    // Present an error alert
                    strongSelf.presentErrorAlert(title: "Error Deleting", message: "Error occured while deleting, please try again")
                }
            })
            
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

// MARK: - Text Field Delegate

extension AddEditClassTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameField { textField.resignFirstResponder() }
        updateSaveButton()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        updateSaveButton()
    }
}


// MARK: - UIRubricView Delegate

extension AddEditClassTableViewController: UIRubricViewDelegate {
    
    /// The done button was tapped, end editing
    func rubricWeightFieldDone(sender: Any) {
        self.view.endEditing(true)
    }
    
    func rubricNeedsCalculate(sender: Any) {
        guard let calculateButton = sender as? UIBarButtonItem, let buttonView = calculateButton.value(forKeyPath: "view") as? UIView,
            let calculateToolbar = buttonView.superview as? UIToolbar else {
            return
        }
        
        var rubricViewToCalculate: UIRubricView?
        // Find the view which needs calculation to be done on
        for cell in rubricCells {
            if calculateToolbar === cell.rubricView.weightField.inputAccessoryView { rubricViewToCalculate = cell.rubricView }
        }

        let calculateAlert = UICalculateViewController(completion: { percent in
            rubricViewToCalculate?.weightField.text = "\(percent)%"
            rubricViewToCalculate?.weightField.editingChanged()
            rubricViewToCalculate?.updateIsRubricValid()
        })
        
        self.present(calculateAlert, animated: true, completion: nil)
    }
    
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
        // Animate the view
        cell.rubricView.animateViews()
        
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
    
    func handleCloseState(forCell cell: RubricTableViewCell, shouldPresentAlert shouldAlert: Bool = true) {
        guard let row = rubricCells.index(of: cell), numOfRubricViewsToDisplay > 1 else {
            fatalError("Could not find rubric view to delete")
        }
        
        // If editing keep track of removed rubric, this method can be called when we want to simply handle the close state
        // If so then shouldAdd will be nil and we wont readd this to the rubricsToDelete array
        if let _ = classObj, shouldAlert {
            // Present an alert warning the user that removing this rubric will also delete any of its associated assignments
            if let primaryKey = (editingRubrics as NSDictionary).allKeys(for: cell).first as? String {
                
                let titleAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName : UIColor.sunsetOrange]
                let title = NSAttributedString(string: "Remove Associated Assignments", attributes: titleAttrs)
                let messageAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName : UIColor.mutedText]
                let message = "Removing this rubric will also delete any assignments that were created under it, are you sure?"
                let messageAttributed = NSAttributedString(string: message, attributes: messageAttrs)
                
                // Present the alert, send it the primary key so that the button for deletion in the alert can handle adding to rubricsToDelete,
                // Also send it the cell which should be closed if user decides to delete
                self.present(alert: .deletion, withTitle: title, andMessage: messageAttributed, options: [cell, primaryKey])
                return
            }
        }
        
        // Animate the view
        cell.rubricView.animateViews()
        
        // Decrease num of rubric views to display since we just deleted one
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
    }
}

// MARK: - Semester Picker Delegate

extension AddEditClassTableViewController: SemesterPickerDelegate {
    func pickerRowSelected(term: String, year: Int) {
        // User selected a semester, lets update the UI
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! GenericLabelTableViewCell
        cell.rightLabel.text = "\(term) \(year)"
        // Set the properties
        self.term = term
        self.year = year
    }
    
    // Helper Methods
    
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
    
    /// Updates the semester picker with values of the class that is passed in
    func updateSemesterPicker(for classObj: Class) {
        guard let pickerCell = semesterPicker, let picker = pickerCell.semesterPicker else {
            fatalError("Unable to update semester picker, has not been loaded yet")
        }
        
        // Since we're done displaying section 0, which contains the semester picker we can go ahead and set its values
        // to what was saved into realm
        // Set the semester picker to correct values
        let iTerm = pickerCell.terms.index(of: classObj.semester!.term)!
        let iYear = pickerCell.years.index(of: classObj.semester!.year)!
        picker.selectRow(iTerm, inComponent: 0, animated: false)
        pickerCell.pickerView(picker, didSelectRow: iTerm, inComponent: 0)
        picker.selectRow(iYear, inComponent: 1, animated: false)
        pickerCell.pickerView(picker, didSelectRow: iYear, inComponent: 1)
    }
}
