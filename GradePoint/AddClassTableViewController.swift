//
//  AddClassTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class AddClassTableViewController: UITableViewController,
                                  UIRubricViewDelegate, UITextFieldDelegate, SemesterPickerDelegate, BlurAlertControllerDelegate {
    
    // MARK: - Properties
    
    // Realm database object
    
    
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
    
    // An array of rubric views that the controller will deal with (provided from the UIRubricTableViewCell)
    lazy var rubricViews = [UIRubricView]()
    
    // The namefield which this controller handles, this field is part of the BasicInfoTableViewCell
    var nameField: UITextField!
    
    // Stored variable for cells, since I dont want to reuse them and lose any input user has put in
    var nameCell: BasicInfoNameTableViewCell?
    var semesterCell: BasicInfoSemesterTableViewCell?
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
    var isIpad = false
    var isPresentingAlert: Bool?
    var isDatePickerVisible = false
    var semesterPicker: UISemesterPickerView?
    
    // The vars for the the finished class user is creating
    // These two are set using the picker view and get set in the pickerdelegate
    var term: String?
    var year: Int?
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Since were handling the picker view differently for ipad vs iphone, then figure out which device user has
        // Then cache that value
        if UIDevice.current.userInterfaceIdiom == .pad { isIpad = true }
        // Disable save button until fields are checked
        saveButton.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = UIColor.tableViewSeperator
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
        mainView.backgroundColor = UIColor.lightBg
        
        let label = UILabel(frame: CGRect(x: 20, y: 0, width: mainView.bounds.size.width, height: 44))
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = UIColor.unselected
        label.backgroundColor = UIColor.lightBg
        mainView.addSubview(label)
        
        switch section {
        case 0:
            label.text = "BASIC INFORMATION"
            return mainView
        case 1:
            label.text = "GRADE RUBRIC"
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
            if isIpad { return 2 }
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
                
                let cell = BasicInfoNameTableViewCell(style: .default, reuseIdentifier: nil)
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.classNameField.delegate = self
                cell.classNameField.addTarget(self, action: #selector(self.updateSaveButton), for: .editingChanged)
                nameField = cell.classNameField
                nameCell = cell
                return cell
            case 1: // Display the basic info date picker cell
                if let c = semesterCell { return c }
                
                let cell = BasicInfoSemesterTableViewCell(style: .default, reuseIdentifier: nil)
                cell.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.delegate = self
                semesterCell = cell
                return cell
            case 2:
                if let c = semesterPickerCell { return c }
                let cell = BasicInfoSemesterPickerTableViewCell(style: .default, reuseIdentifier: nil)
                cell.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
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
            rubricCells.append(cell)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
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
    
    func dateInputWasTapped(forCell cell: BasicInfoSemesterTableViewCell) {
        if isIpad { // Display the semester picker as a popover, cus it looks cooler
            let vc = IPadSemesterPickerViewController()
            vc.preferredContentSize = CGSize(width: 200, height: 100)
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.sourceView = cell.dateInputLabel
            vc.semesterPicker.delegate = self
            self.saveButton.isEnabled = false
            self.present(vc, animated: true, completion: { [unowned self] in
                // Completion handler
                self.saveButton.isEnabled = true
            })
            return
        }
        
        // Not on ipad, present the date picker as a cell or hide it if already showing
        if isDatePickerVisible { hideDatePicker() }
        else { showDatePicker() }
    }
    
    func pickerRowSelected(term: String, year: Int) {
        // User selected a date, lets update the UI
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! BasicInfoSemesterTableViewCell
        cell.dateInputLabel.text = "\(term) \(year)"
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
                    presentAlert(withTitle: "Can't Save 💔", andMessage: "Zero percentage is invalid in row \(i + 1)")
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
            print(self.term)
            print(self.year)
            let semester = Semester(withTerm: self.term!, andYear: self.year!) // Unwrapped because, we're already saving, if these are optional something went wrong
            let rubricList = List<Rubric>(rubrics)
            let newClass = Class(withName: nameField.text!, inSemester: semester, withRubrics: rubricList)
            

        } else { presentAlert(withTitle: "Can't Save 💔", andMessage: "Weights must add up to 100%") }
    }
    
    // - MARK: Helper Methods

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
    
    func showDatePicker() {
        guard let picker = semesterPicker else {
            print("Picker not available")
            return
        }
        
        // Show the date picker
        tableView.beginUpdates()
        isDatePickerVisible = true
        tableView.endUpdates()
        picker.isHidden = false
        picker.alpha = 0.0
        // Animate the show
        UIView.animate(withDuration: 0.3) { 
            picker.alpha = 1.0
        }
        
    }
    
    func hideDatePicker() {
        guard let picker = semesterPicker else {
            print("Picker not available")
            return
        }
        
        // Hide the date picker
        tableView.beginUpdates()
        isDatePickerVisible = false
        tableView.endUpdates()
        picker.isHidden = true
        picker.alpha = 1.0
        // Animate the show
        UIView.animate(withDuration: 0.3) {
            picker.alpha = 0.0
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
    
    func presentAlert(withTitle title: String, andMessage msg: String) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let alert = board.instantiateViewController(withIdentifier: "blurAlertController") as! BlurAlertController
        alert.view.frame = self.view.frame
        alert.alertTitle = title
        alert.alertMessage = msg
        alert.buttonText = "OK"
        alert.buttonColor = UIColor.highlight
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
}
