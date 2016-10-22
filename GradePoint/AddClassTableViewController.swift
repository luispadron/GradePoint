//
//  AddClassTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class AddClassTableViewController: UITableViewController, UIRubricViewDelegate, UITextFieldDelegate, SemesterPickerDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    // An array of rubric views that the controller will deal with (provided from the UIRubricTableViewCell)
    lazy var rubricViews = [UIRubricView]()
    // The current rubric view that is being edited or selected, set whenever user clicks the plus button
    var currentRubricView: UIRubricView?
    
    // The namefield which this controller handles, this field is part of the BasicInfoTableViewCell
    var nameField: UITextField?
    
    var numOfRubricViews = 1
    var isIpad = false
    var isDatePickerVisible = false
    var semesterPicker: UISemesterPickerView?
    
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Since were handling the picker view differently for ipad vs iphone, then figure out which device user has
        // Then cache that value
        if UIDevice.current.userInterfaceIdiom == .pad { isIpad = true }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.separatorColor = UIColor.tableViewSeperator
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
                let cell = BasicInfoNameTableViewCell(style: .default, reuseIdentifier: nil)
                cell.contentView.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.classNameField.delegate = self
                nameField = cell.classNameField
                return cell
            case 1: // Display the basic info date picker cell
                let cell = BasicInfoSemesterTableViewCell(style: .default, reuseIdentifier: nil)
                cell.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.delegate = self
                return cell
            case 2:
                let cell = BasicInfoSemesterPickerTableViewCell(style: .default, reuseIdentifier: nil)
                cell.backgroundColor = UIColor.darkBg
                cell.selectionStyle = .none
                cell.semesterPicker.delegate = self
                semesterPicker = cell.semesterPicker
                return cell
            default:
                break
            }
            
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "rubricCell", for: indexPath) as! RubricTableViewCell
            cell.selectedBackgroundView = emptyView
            cell.rubricView.delegate = self
            // Assign the rubric views textfield delegates
            cell.rubricView.nameField.delegate = self
            cell.rubricView.weightField.delegate = self
            // Add this to the tracking array of views for this controller
            addViewToArray(cell.rubricView)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // MARK: - Rubric View Delegate
    
    func plusButtonTouched(_ view: UIRubricView, forState state: UIRubricViewState) {
        switch state {
        case .collapsed:
            // Handle user cancelling that item
            handleCloseState(withRubricView: view)
        case .open:
            // Handle user wanting to add a grade section
            handleOpenState(withRubricView: view)
        }
    }
    
    // MARK: - Date Input Delegate
    
    func dateInputWasTapped(forCell cell: BasicInfoSemesterTableViewCell) {
        if isIpad { // Display the date picker as a popover, cus it looks cooler
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
    
    func pickerRowSelected(semester: String, year: Int) {
        // User selected a date, lets update the UI
        let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! BasicInfoSemesterTableViewCell
        cell.dateInputLabel.text = "\(semester) \(year)"
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // - MARK: IBActions
    
    @IBAction func onCancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSave(_ sender: AnyObject) {
    }
    
    // - MARK: Helper Methods
    
    func addViewToArray(_ view: UIRubricView) {
        if rubricViews.contains(view) { return }
        else { rubricViews.append(view) }
    }

    func handleOpenState(withRubricView view: UIRubricView) {
        // If it's not the last rubric view then dont add another since we only want to 
        // add a new rubric input view when ever the use has exhausted all the others
        if view !== rubricViews[rubricViews.count - 1] { return }
        
        // Last rubric view, lets create another one for the use incase they want to enter something
        let path = IndexPath(row: numOfRubricViews, section: 1)
        self.numOfRubricViews += 1
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
            self.tableView.scrollToRow(at: path, at: .bottom, animated: true)
        }
        // Set the current rubric view
        currentRubricView = view
    }
    
    func handleCloseState(withRubricView view: UIRubricView) {
        guard let row = rubricViews.index(of: view), numOfRubricViews > 1 else {
            print("FATAL ERROR: Could not find rubric view to delete")
            return
        }
        
        self.numOfRubricViews -= 1
        rubricViews.remove(at: row)
        
        let path = IndexPath(row: row, section: 1)
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [path], with: .automatic)
            self.tableView.endUpdates()
        }
        // Remove current rubric view 
        currentRubricView = nil
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
        isDatePickerVisible = false
        tableView.beginUpdates()
        tableView.endUpdates()
        picker.isHidden = true
        picker.alpha = 1.0
        // Animate the show
        UIView.animate(withDuration: 0.3) {
            picker.alpha = 0.0
        }
    }
}
