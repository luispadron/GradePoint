//
//  AddEditClassViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/22/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

enum ViewState {
    case inProgress
    case past
}

class AddEditClassViewController: UIViewController {

    // MARK: Properties
    
    let realm = try! Realm()
    var classObj: Class?
    lazy var colorForView: UIColor = {
        if let obj = self.classObj { return obj.color }
        else { return UIColor.randomPastel }
    }()
    
    let heightForRubricView: CGFloat = 70.0
    
    ///// VIEWS
    // Nav bar
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    // View content
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    // Controls
    @IBOutlet weak var typeSwitcher: UISegmentedControl!
    @IBOutlet weak var nameField: UISafeTextField!
    @IBOutlet weak var classTypeView: UIView!
    @IBOutlet weak var classTypeLabel: UILabel!
    @IBOutlet weak var classTypePickerView: UIPickerView!
    @IBOutlet weak var classTypePickerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var creditHoursField: UISafeTextField!
    @IBOutlet weak var semesterLabel: UILabel!
    @IBOutlet weak var semesterPickerView: UISemesterPickerView!
    @IBOutlet weak var semesterPickerConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradeFieldContainerView: UIView!
    @IBOutlet weak var gradeLabel: UILabel!
    @IBOutlet weak var gradePickerView: UIPickerView!
    @IBOutlet weak var gradePickerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var rubricHeaderView: UIView!
    
    /// Properties to handle the save button
    var canSave = false { didSet { saveButton.isEnabled = canSave } }
    var rubricViewsAreValid = false { didSet { canSave = rubricViewsAreValid && nameFieldIsValid } }
    var nameFieldIsValid = false { didSet { canSave = nameFieldIsValid && rubricViewsAreValid }}
    
    /// An array which will hold all the rubric views which have been created
    var rubricViews: [UIRubricView] {
        get {
            let views = self.stackView.arrangedSubviews
            var result = [UIRubricView]()
            for view in views { if let v = view as? UIRubricView { result.append(v) } }
            return result
        }
    }
    /// Dict which holds any rubric views and that rubrics PK, which were intially added to the view due to editing a class
    var editingRubrics = [String: UIRubricView]()
    /// Any rubrics which were being edited and the user now wants to delete will be added to this array, stores the pk of the rubric to delete
    var rubricsToDelete = [String]()
    
    ///// Variables
    /// The class type, grabbed from the Picker
    var classType: ClassType!
    /// The semester, grabbed from the UISemesterPickerView
    var semester: Semester!
    
    /// The delegate for this view, will be notified when finished editing or creating new class
    weak var delegate: AddEditClassViewDelegate?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        self.navigationView.backgroundColor = colorForView
        let visibleColor = colorForView.visibleTextColor(lightColor: UIColor.mainText, darkColor: UIColor.darkText)
        self.cancelButton.tintColor = visibleColor
        self.saveButton.setTitleColor(visibleColor, for: .normal)
        let visibleDisabledColor = colorForView.visibleTextColor(lightColor: UIColor.mutedText, darkColor: UIColor.gray)
        self.saveButton.setTitleColor(visibleDisabledColor, for: .disabled)
        self.navigationTitle.textColor = visibleColor
        
        // Customization for the fields
        let attrsForPrompt = [NSForegroundColorAttributeName: UIColor.mutedText, NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        
        self.nameField.textColor = UIColor.white
        self.nameField.attributedPlaceholder = NSAttributedString(string: "Class Name", attributes: attrsForPrompt)
        self.nameField.delegate = self
        self.nameField.addTarget(self, action: #selector(updateSaveButton), for: .editingChanged)
        self.nameField.autocapitalizationType = .words
        self.nameField.returnKeyType = .next
        
        // Get student type from user defaults
        let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: UserPreferenceKeys.studentType.rawValue))
        
        // Set default class type
        self.classType = studentType == StudentType.college ? .college : .regular
        self.classTypeLabel.text = studentType == StudentType.college ? nil : "Regular"
        // Hide the class type view if student is a college student
        self.classTypeView.isHidden = studentType == StudentType.college ? true : false
        
        self.creditHoursField.textColor = UIColor.white
        let defaultCredits = studentType == StudentType.college ? "3" : "1"
        self.creditHoursField.attributedPlaceholder = NSAttributedString(string: defaultCredits, attributes: attrsForPrompt)
        self.creditHoursField.delegate = self
        self.creditHoursField.keyboardType = .numbersAndPunctuation
        self.creditHoursField.returnKeyType = .done
        self.creditHoursField.autocorrectionType = .no
        self.creditHoursField.configuration = NumberConfiguration(allowsSignedNumbers: false, range: 0.1...30)
        self.creditHoursField.fieldType = .number
        
        // Set the delegate for the pickers
        self.classTypePickerView.delegate = self
        self.classTypePickerView.dataSource = self
        self.semesterPickerView.delegate = self
        self.gradePickerView.delegate = self
        self.gradePickerView.dataSource = self
        
        // Initially we need to have at least one rubric view added to the view
        if rubricViews.isEmpty && self.classObj == nil { appendRubricView() }
        
        self.saveButton.isEnabled = false
        
        // If were editing a class then update the UI
        if let classObj = self.classObj {
            self.navigationTitle.text = "Edit \(classObj.name)"
            self.nameField.text = classObj.name
            self.classTypeLabel.text = classObj.classType.name()
            updateClassTypePicker(for: classObj)
            self.creditHoursField.text = "\(classObj.creditHours)"
            updateSemesterPicker(for: classObj)
            updateRubricViews(for: classObj)
        } else {
            // Set a default semester
            let semester = Semester(withTerm: self.semesterPickerView.selectedSemester, andYear: self.semesterPickerView.selectedYear)
            self.semesterLabel.text = "\(semester.term) \(semester.year)"
            self.semester = semester
            // Set a default grade
            let scale = try! Realm().objects(GPAScale.self).first!
            let defaultGrade = scale.gpaRubrics[0].gradeLetter
            self.gradeLabel.text = defaultGrade
        }
        
        // If not on iPad where the view will be presented as a popover
        if !(UIDevice.current.userInterfaceIdiom == .pad) {
            // Setup keyboard notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        }
        // Notify of nav bar color changes
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set status bar color
        let color = self.colorForView.isLight() ? UIStatusBarStyle.default : UIStatusBarStyle.lightContent
        UIApplication.shared.statusBarStyle = color
        self.setNeedsStatusBarAppearanceUpdate()
        
        updateSaveButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Revert status bar changes
        UIApplication.shared.statusBarStyle = .lightContent
        // Remove any notifications
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    // MARK: Actions
    
    @IBAction func onCancel(_ sender: UIButton) {
        // Quickly animate the cancel button rotation and dismiss
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.cancelButton.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }) { (finished) in
            if finished { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @IBAction func onViewSwitchTapped(_ sender: UISegmentedControl) {
        // End any editing
        self.view.endEditing(true)
        // Update the view
        
        switch sender.selectedState {
        // Show all the views EXCEPT the grade selection view
        case .inProgress:
            // Initial set up
            self.rubricHeaderView.isHidden = false
            for v in self.rubricViews { v.isHidden = false }
            
            UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeCubic, animations: { 
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.gradeFieldContainerView.layoutIfNeeded()
                    self.gradeFieldContainerView.alpha = 0.0
                    self.gradePickerView.alpha = 0.0
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                    self.rubricHeaderView.alpha = 1.0
                    for v in self.rubricViews { v.alpha = 1.0 }
                })
                
            }, completion: { _ in
                self.gradeFieldContainerView.isHidden = true
                self.gradePickerView.isHidden = true
                self.updateSaveButton()
            })
        // Hide any rubric views, and show the grade selection view
        case .past:
            // Initial set up
            self.gradeFieldContainerView.isHidden = false
            self.gradePickerView.isHidden = false
            UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeCubic, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.rubricHeaderView.alpha = 0.0
                    for v in self.rubricViews { v.alpha = 0.0 }
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                    self.gradeFieldContainerView.alpha = 1.0
                    self.gradePickerView.alpha = 1.0
                })
                
            }, completion: { _ in
                self.rubricHeaderView.isHidden = true
                for v in self.rubricViews { v.isHidden = true }
                self.updateSaveButton()
            })
        }

    }
    
    @IBAction func onClassTypeTap(_ sender: UITapGestureRecognizer) {
        toggleVisibilty(for: self.classTypePickerView)
    }
    
    @IBAction func onSemesterTap(_ sender: UITapGestureRecognizer) {
        toggleVisibilty(for: self.semesterPickerView)
    }
    
    @IBAction func onGradeFieldTap(_ sender: UITapGestureRecognizer) {
        toggleVisibilty(for: self.gradePickerView)
    }

    /// Called whenever keyboard is shown, adjusts scroll view
    func keyboardDidShow(notification: Notification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /// Called whenever keyboard is shown, adjusts scroll view
    func keyboardWillHide(notification: Notification) {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: Save Methods
    
    @IBAction func onSave(_ sender: UIButton) {
        guard isSaveReady() else { return }
        // Switch on state, save the correct type of class
        switch typeSwitcher.selectedState {
        case .inProgress:
            guard let classObj = self.classObj else { saveNewInProgressClass(); return }
            saveChangesTo(inProgressClass: classObj)
        case .past:
            guard let classObj = self.classObj else { saveNewPastClass(); return }
            saveChangesTo(pastClass: classObj)
        }
    }
    
    // Checks the fields, makes sure percents add up to 100%, etc, if not presents alert
    func isSaveReady() -> Bool {
        // If adding a past class, this checking of rubrics can be skipped
        guard self.typeSwitcher.selectedState == .inProgress else { return true }
        // Want all rubric cells except the last one, since its always empty
        var views = rubricViews
        views.removeLast()
        
        // Keep track of total percent while looping
        var totalPercent: Double = 0.0
        
        for (index, view) in views.enumerated() {
            guard let percent = Double(view.weightField.safeText) else {
                presentErrorAlert(title: "Unable to save", message: "Some data is incorrect and cannot save, please check values and try again")
                return false
            }
            
            if percent <= 0 {
                // Present alert warning user about zero percent
                // Construct title
                let title = NSAttributedString(string: "Can't Save 💔", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 17)])
                // Construct attributed message
                let invalidRowSubmessage = "row \(index + 1)"
                let attrsForSub = [NSForegroundColorAttributeName : UIColor.warning, NSFontAttributeName : UIFont.systemFont(ofSize: 15)]
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
    
    /// Saves a new class object to realm with all the data the user entered
    func saveNewInProgressClass() {
        // Want all rubric cells except the last one, since its always empty
        var views = rubricViews
        views.removeLast()
        
        // Rubrics to be created in realm
        var rubrics = [Rubric]()
        // Loop through the rubric cells and append rubrics to the rubrics array, can force unwrap since already checked for values
        for view in views {
            // Get rubric info
            let rubricWeight = Double(view.weightField.safeText)!
            let rubricName = view.nameField.text!
            rubrics.append(Rubric(withName: rubricName, andWeight: rubricWeight))
        }
        
        // Create the semester
        let semester = Semester(withTerm: self.semester.term, andYear: self.semester.year)
        
        let credits = Int(self.creditHoursField.safeText) ?? Int(self.creditHoursField.placeholder!)!
        // Create the new class
        let newClass = Class(name: self.nameField.safeText, classType: self.classType,
                             creditHours: credits, semester: semester, rubrics: List<Rubric>(rubrics))
        newClass.colorData = colorForView.toData()
        
        try! realm.write {
            realm.add(newClass)
        }
        
        
        // Dismiss controller
        self.dismiss(animated: true) { [weak self] in
            // Call the delegate tell it were done creating this class
            self?.delegate?.didFinishCreating(newClass: newClass)
        }
    }
    
    func saveNewPastClass() {
        let semester = Semester(withTerm: self.semester.term, andYear: self.semester.year)
        let credits = Int(self.creditHoursField.safeText) ?? Int(self.creditHoursField.placeholder!)!
        let newClass = Class(name: self.nameField.safeText, classType: self.classType, creditHours: credits,
                             semester: semester, grade: Grade(gradeLetter: self.gradeLabel.text!))
        newClass.colorData = colorForView.toData()
        // Write the new class to realm
        try! realm.write {
            realm.add(newClass)
        }
        
        // Dismisses
        self.dismiss(animated: true) { [weak self] in
            // Call delegate, notify of new class
            self?.delegate?.didFinishCreating(newClass: newClass)
        }
    }
    
    /// Saves the edits the user made to the object
    func saveChangesTo(inProgressClass classObj: Class) {
        // Lets save the changes made to the Class object, again can force unwrap since already checked for values
        
        // Write name and semester changes to realm
        try! realm.write {
            classObj.name = self.nameField.safeText
            classObj.classType = self.classType
            classObj.creditHours = Int(self.creditHoursField.safeText) ?? Int(self.creditHoursField.placeholder!)!
            classObj.semester?.term = self.semester.term
            classObj.semester?.year = self.semester.year
        }
        
        // Delete any rubrics
        self.deleteRubrics()
        
        // The rubric views which will be added
        var rubricViews = self.rubricViews
        rubricViews.removeLast()
        
        // Loop through the rubric views and save any changes/add new rubrics
        for (pk, rubricView) in editingRubrics {
            let savedRubric = realm.object(ofType: Rubric.self, forPrimaryKey: pk)!
            try! realm.write {
                savedRubric.name = rubricView.nameField.safeText
                savedRubric.weight = Double(rubricView.weightField.safeText)!
            }
            // Remove this rubric from the rubricViews array, since was already updated, and should not be created again
            if let index = rubricViews.index(of: rubricView) { rubricViews.remove(at: index) }
        }
        
        // Add any new rubric views
        for rubricView in rubricViews {
            let name = rubricView.nameField.safeText
            let weight = Double(rubricView.weightField.safeText)!
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
    
    func saveChangesTo(pastClass classObj: Class) {
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
    
    // MARK: Helper Methods
    
    /// Adds a new rubric view to the stack view, returns the view which was added
    @discardableResult func appendRubricView() -> UIRubricView {
        let rubricView = UIRubricView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForRubricView))
        rubricView.delegate = self
        rubricView.heightAnchor.constraint(equalToConstant: heightForRubricView).isActive = true
        self.stackView.addArrangedSubview(rubricView)
        return rubricView
    }
    
    /// Removes the specified view from the stack view
    func removeRubricView(_ view: UIRubricView) {
        view.animateViews()
        UIView.animate(withDuration: view.animationDuration, animations: {
            view.alpha = 0.0
        }, completion: { _ in
            self.stackView.removeArrangedSubview(view)
        })
    }
    
    func updateSaveButton() {
        // Checks to see whether should enable save button
        let nameValid = self.nameField.safeText.isValid()
        
        // Different case for selected states
        switch self.typeSwitcher.selectedState {
        case .inProgress:
            var rubricsAreValid = false
            var validCount = 0
            for view in rubricViews { if view.isRubricValid { validCount += 1 } }
            rubricsAreValid = validCount != 1 && (validCount == rubricViews.count)
            
            self.saveButton.isEnabled = nameValid && rubricsAreValid
        case .past:
            self.saveButton.isEnabled = nameValid
            break
        }
    }
    
    func updateClassTypePicker(for classObj: Class) {
        let row = classObj.classType.rawValue - 1
        self.classTypePickerView.selectRow(row, inComponent: 0, animated: false)
        self.pickerView(self.classTypePickerView, didSelectRow: row, inComponent: 0)
    }
    
    /// Updates the semester picker with values of the class that is passed in
    func updateSemesterPicker(for classObj: Class) {
        
        // Set the semester picker to correct values
        let picker = self.semesterPickerView.semesterPicker!
        let iTerm = self.semesterPickerView.terms.index(of: classObj.semester!.term)!
        let iYear = self.semesterPickerView.years.index(of: classObj.semester!.year)!
        
        picker.selectRow(iTerm, inComponent: 0, animated: false)
        self.semesterPickerView.pickerView(picker, didSelectRow: iTerm, inComponent: 0)
        picker.selectRow(iYear, inComponent: 1, animated: false)
        self.semesterPickerView.pickerView(picker, didSelectRow: iYear, inComponent: 1)
        
        self.semester = classObj.semester!
    }
    
    func updateRubricViews(for classObj: Class) {
        for rubric in classObj.rubrics {
            let view = appendRubricView()
            view.nameField.text = rubric.name
            view.weightField.text = "\(rubric.weight)%"
            view.toEditState()
            self.editingRubrics[rubric.id] = view
        }
     
        // Append a new rubric view to the end
        appendRubricView()
    }
    
    /// Shows or hides a pickerview
    private func toggleVisibilty(for pickerView: UIView) {
        
        var constraint: NSLayoutConstraint?
        var label: UILabel?
        
        if pickerView === classTypePickerView {
            label = self.classTypeLabel
            constraint = self.classTypePickerViewConstraint
        } else if pickerView === gradePickerView {
            label = self.gradeLabel
            constraint = self.gradePickerViewConstraint
        } else {
            label = self.semesterLabel
            constraint = self.semesterPickerConstraint
        }
        
        let wasHidden = pickerView.isHidden
        pickerView.isHidden = false
        let toAlpha: CGFloat = wasHidden ? 1.0 : 0.0
        let toHeight: CGFloat = wasHidden ? 120.0 : 0.0
        
        UIView.animate(withDuration: 0.4, animations: {
            pickerView.alpha = toAlpha
            constraint?.constant = toHeight
            label?.textColor = wasHidden ? UIColor.highlight : UIColor.white
        }, completion: { _ in
            pickerView.isHidden = !wasHidden
        })
    }
    
    /// Presents an alert when provided the specified alertType
    func present(alert type: AlertType, withTitle title: NSAttributedString, andMessage message: NSAttributedString, options: [Any]? = nil) {
        // The alert controller
        let alert = UIBlurAlertController(size: CGSize(width: 300, height: 200), title: title, message: message)
        
        switch type {
            
        case .message:
            // Add the ok button
            let button = UIButton()
            button.setTitle("OK", for: .normal)
            button.backgroundColor = UIColor.info
            alert.addButton(button: button, handler: nil)
            
        case .deletion:
            // Set alert type
            alert.alertFeedbackType = .warning
            // Create and add the cancel button
            let cancel = UIButton()
            cancel.setTitle("Cancel", for: .normal)
            cancel.backgroundColor = UIColor.info
            alert.addButton(button: cancel, handler: nil)
            
            // Create and add the delete button
            let delete = UIButton()
            delete.setTitle("Delete", for: .normal)
            delete.backgroundColor = UIColor.warning
            alert.addButton(button: delete, handler: { [weak self] in
                guard let strongSelf = self else {
                    print("Unable to get self inside delete handler, class: \(AddEditClassViewController.self)")
                    return
                }
                
                // If calling this method with .delete then we have been sent the view and pk in the options
                if let opts = options, opts.count > 0, let view = opts[0] as? UIRubricView, let pk = opts[1] as? String {
                    // Add this rubrics pk to the rubricsToDelete array, will be deleted when saving
                    strongSelf.rubricsToDelete.append(pk)
                    // Don't present the alert asking if they wish to delte again but close the view and make it look delete
                    strongSelf.removeRubricView(view)
                } else {
                    // Present an error alert
                    strongSelf.presentErrorAlert(title: "Error Deleting", message: "Error occured while deleting, please try again")
                }
            })
            
            break
        }
        
        // Present the alert
        alert.presentAlert(presentingViewController: self)
    }
}

// MARK: ScrollView Delegate
extension AddEditClassViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Remove first responder from name field, since keyboard is really annoying
        if nameField.isFirstResponder { nameField.resignFirstResponder() }
        else if creditHoursField.isFirstResponder { creditHoursField.resignFirstResponder() }
    }
}

// MARK: - Text Field Delegate
extension AddEditClassViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UISafeTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameField { // When hitting next, go to credit hours field
            textField.resignFirstResponder()
            creditHoursField.becomeFirstResponder()
        } else if textField === creditHoursField {
            creditHoursField.resignFirstResponder()
        }
        
        updateSaveButton()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        updateSaveButton()
    }
}

// MAKR: Class Type & Grade Picker Delegation/DataSource
extension AddEditClassViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    var classTypes: [String] {
        get {
            return ["Regular", "Honors", "AP", "IB", "College"]
        }
    }
    
    var gradeLetters: [String] {
        get {
            let scale = try! Realm().objects(GPAScale.self)[0]
            return scale.gpaRubrics.map { $0.gradeLetter }
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView === self.classTypePickerView ? classTypes.count : gradeLetters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = pickerView === self.classTypePickerView ? classTypes[row] : gradeLetters[row]
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Update the label and the class type
        if pickerView === self.classTypePickerView {
            self.classTypeLabel.text = classTypes[row]
            self.classType = ClassType(rawValue: row + 1)
        } else {
            self.gradeLabel.text = gradeLetters[row]
        }
    }
}

// MARK: Semester Picker Delegation
extension AddEditClassViewController: SemesterPickerDelegate {
    /// Notifies delegate that a row was selected
    internal func pickerRowSelected(term: String, year: Int) {
        self.semesterLabel.text = "\(term) \(year)"
        self.semester = Semester(withTerm: term, andYear: year)
    }
}

// MARK: Rubric View Delegation
extension AddEditClassViewController: UIRubricViewDelegate {
    /// Notifies delgate that the rubrics valid state was updated
    internal func isRubricValidUpdated(forView view: UIRubricView) {
        updateSaveButton()
    }

    /// Notifies delegate that the plus button was touched
    internal func plusButtonTouched(_ view: UIRubricView, withState state: UIRubricViewState?) {
        guard let `state` = state else { return }
    
        switch state {
        case .open:
            // User is about to close a rubric which was previously created, warn them what this means
            if let primaryKey = (editingRubrics as NSDictionary).allKeys(for: view).first as? String {
                let titleAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName : UIColor.warning]
                let title = NSAttributedString(string: "Remove Associated Assignments", attributes: titleAttrs)
                let messageAttrs = [NSFontAttributeName : UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName : UIColor.mutedText]
                let message = "Removing this rubric will also delete any assignments that were created under it, are you sure?"
                let messageAttributed = NSAttributedString(string: message, attributes: messageAttrs)
                
                // Present the alert, send it the primary key so that the button for deletion in the alert can handle adding to rubricsToDelete,
                // Also send it the cell which should be closed if user decides to delete
                self.present(alert: .deletion, withTitle: title, andMessage: messageAttributed, options: [view, primaryKey])
            } else {
                self.removeRubricView(view)
            }
        case .collapsed:
            view.animateViews()
            self.appendRubricView()
        }
    }
    
    /// Notifies when the weight fields keyboard 'Calculate' button was tapped
    internal func calculateButtonWasTapped(forView view: UIRubricView, textField: UITextField) {
        let calculateAlert = UICalculateViewController(completion: { percent in
            view.weightField.text = "\(percent)%"
            view.weightField.editingChanged()
            view.updateIsRubricValid()
        })
        
        self.present(calculateAlert, animated: true, completion: nil)
    }

}
