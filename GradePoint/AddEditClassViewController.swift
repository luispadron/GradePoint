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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
        guard let classObj = self.classObj else { saveNewClass(); return }
        saveUpdate(for: classObj)
    }
    
    func saveNewClass() {
        let name = nameField.safeText
        let semester = self.semester
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
