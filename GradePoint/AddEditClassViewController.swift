//
//  AddEditClassViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/22/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

class AddEditClassViewController: UIViewController, UIScrollViewDelegate {

    // MARK: Properties
    
    let realm = try! Realm()
    var classObj: Class?
    
    ///// CONSTANTS
    let colorForView: UIColor = UIColor.randomPastel
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
    // Fields
    @IBOutlet weak var nameField: UISafeTextField!
    @IBOutlet weak var semesterLabel: UILabel!
    @IBOutlet weak var semesterPickerView: UISemesterPickerView!
    @IBOutlet weak var semesterPickerConstraint: NSLayoutConstraint!
    
    /// Properties to handle the save button
    var canSave = false { didSet { saveButton.isEnabled = canSave } }
    var rubricViewsAreValid = false { didSet { canSave = rubricViewsAreValid && nameFieldIsValid } }
    var nameFieldIsValid = false { didSet { canSave = nameFieldIsValid && rubricViewsAreValid }}
    var isPresentingAlert: Bool?
    
    /// An array which will hold all the rubric views which have been created
    var rubricViews: [UIRubricView] {
        get {
            let views = self.stackView.arrangedSubviews
            var result = [UIRubricView]()
            for view in views { if let v = view as? UIRubricView { result.append(v) } }
            return result
        }
    }
    
    ///// Variables
    /// The semester, grabbed from the UISemesterPickerView
    var semester: Semester!
    
    /// The delegate for this view, will be notified when finished editing or creating new class
    weak var delegate: AddEditClassViewDelegate?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        self.navigationView.backgroundColor = colorForView
        let visibleColor = colorForView.visibleTextColor(lightColor: UIColor.lightText, darkColor: UIColor.darkText)
        self.cancelButton.tintColor = visibleColor
        self.saveButton.setTitleColor(visibleColor, for: .normal)
        let visibleDisabledColor = colorForView.visibleTextColor(lightColor: UIColor.mutedText, darkColor: UIColor.gray)
        self.saveButton.setTitleColor(visibleDisabledColor, for: .disabled)
        self.navigationTitle.textColor = visibleColor
        
        self.nameField.textColor = UIColor.white
        let attrsForPrompt = [NSForegroundColorAttributeName: UIColor.mutedText, NSFontAttributeName: UIFont.systemFont(ofSize: 17)]
        self.nameField.attributedPlaceholder = NSAttributedString(string: "Class Name", attributes: attrsForPrompt)
        self.nameField.delegate = self
        self.nameField.addTarget(self, action: #selector(updateSaveButton), for: .editingChanged)
        
        semesterPickerConstraint.constant = 0.0
        semesterPickerView.delegate = self
        
        // Initially we need to have at least one rubric view added to the view
        if rubricViews.isEmpty { appendRubricView() }
        
        self.saveButton.isEnabled = false
        
        // If were editing a class then update the UI
        if let classObj = self.classObj {
            self.navigationTitle.text = "Edit \(classObj.name)"
            self.nameField.text = classObj.name
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

        // Set the pickers initial value
        if let obj = classObj {
            updateSemesterPicker(for: obj)
        }
        else {
            let semester = Semester(withTerm: self.semesterPickerView.selectedSemester, andYear: self.semesterPickerView.selectedYear)
            self.semesterLabel.text = "\(semester.term) \(semester.year)"
            self.semester = semester
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Revert status bar changes
        UIApplication.shared.statusBarStyle = .lightContent
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
    
    
    // MARK: Actions
    
    @IBAction func onCancel(_ sender: UIButton) {
        // Quickly animate the cancel button rotation and dismiss
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            self.cancelButton.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }) { (finished) in
            if finished { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @IBAction func onSemesterTap(_ sender: UITapGestureRecognizer) {
        let wasHidden = semesterPickerView.isHidden
        self.semesterPickerView.isHidden = false
        let toAlpha: CGFloat = wasHidden ? 1.0 : 0.0
        let toHeight: CGFloat = wasHidden ? 120.0 : 0.0
        
        UIView.animate(withDuration: 0.4, animations: {
            self.semesterPickerView.alpha = toAlpha
            self.semesterPickerConstraint.constant = toHeight
            self.semesterLabel.textColor = wasHidden ? UIColor.highlight : UIColor.white
        }, completion: { finished in
            if finished { self.semesterPickerView.isHidden = !wasHidden }
        })
    }
    
    
    // MARK: Save Methods
    
    @IBAction func onSave(_ sender: UIButton) {
        guard isSaveReady() else { return }
        guard let classObj = self.classObj else { saveNewClass(); return }
        saveUpdate(for: classObj)
    }
    
    // Checks the fields, makes sure percents add up to 100%, etc, if not presents alert
    func isSaveReady() -> Bool {
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
    
    /// Saves a new class object to realm with all the data the user entered
    func saveNewClass() {
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
    
    func saveUpdate(for classObj: Class) {
        
    }
    
    // MARK: Helper Methods
    
    func appendRubricView() {
        let rubricView = UIRubricView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForRubricView))
        rubricView.delegate = self
        rubricView.heightAnchor.constraint(equalToConstant: heightForRubricView).isActive = true
        self.stackView.addArrangedSubview(rubricView)
    }
    
    func removeRubricView(_ view: UIRubricView) {
        view.animateViews()
        UIView.animate(withDuration: view.animationDuration, animations: {
            view.alpha = 0.0
        }, completion: { finished in
            if finished { self.stackView.removeArrangedSubview(view) }
        })
    }
    
    func updateSaveButton() {
        // Checks to see whether should enable save button
        let nameValid = self.nameField.safeText.isValid()
        var rubricsAreValid = false
        var validCount = 0
        for view in rubricViews { if view.isRubricValid { validCount += 1 } }
        rubricsAreValid = validCount != 1 && (validCount == rubricViews.count)
        print("Name valid: \(nameValid), rubrics valid: \(rubricsAreValid)")
        self.saveButton.isEnabled = nameValid && rubricsAreValid
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
                    print("Unable to get self inside delete handler, class: \(AddEditClassViewController.self)")
                    return
                }
                
//                // If calling this method with .delete then we have been sent the cell and pk in the options
//                if let opts = options, opts.count > 0, let cell = opts[0] as? RubricTableViewCell, let pk = opts[1] as? String {
//                    // Add this rubrics pk to the rubricsToDelete array, will be deleted when saving
//                    strongSelf.rubricsToDelete.append(pk)
//                    // Don't present the alert asking if they wish to delte again but close the view and make it look delete
//                    strongSelf.handleCloseState(forCell: cell, shouldPresentAlert: false)
//                } else {
//                    // Present an error alert
//                    strongSelf.presentErrorAlert(title: "Error Deleting", message: "Error occured while deleting, please try again")
//                }
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
extension AddEditClassViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UISafeTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
    
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
            self.removeRubricView(view)
        case .collapsed:
            view.animateViews()
            self.appendRubricView()
        }
    }

}
