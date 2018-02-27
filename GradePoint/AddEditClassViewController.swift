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
    case inProgressWeighted
    case inProgressPoints
    case previous
}

class AddEditClassViewController: UIViewController {

    // MARK: Properties

    weak var listener: ClassChangesListener? = nil
    
    private let realm = DatabaseManager.shared.realm
    
    var classObj: Class?
    
    private lazy var colorForView: UIColor = {
        if let obj = self.classObj { return obj.color }
        else { return UIColor.randomPastel }
    }()
    
    private let heightForRubricView: CGFloat = 70.0
    
    private var colorTimer: Timer? = nil
    
    ///// VIEWS
    
    // Nav bar
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    // View content
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var headerView1: UIView!
    @IBOutlet weak var headerView2: UIView!
    
    // Controls
    @IBOutlet weak var typeSwitcher: UISegmentedControl!
    
    @IBOutlet weak var classNameField: UIFloatingPromptTextField!
    
    @IBOutlet weak var classTypeView: UIView!
    @IBOutlet weak var classTypeField: UIPickerField!
    
    @IBOutlet weak var creditHoursField: UIFloatingPromptTextField!
    
    @IBOutlet weak var semesterField: UIPickerField!
    
    @IBOutlet weak var gradeFieldContainerView: UIView!
    @IBOutlet weak var gradeField: UIPickerField!
    
    @IBOutlet weak var rubricHeaderView: UIView!
    
    /// Properties to handle the save button
    var canSave = false { didSet { saveButton.isEnabled = canSave } }
    var rubricViewsAreValid = false { didSet { canSave = rubricViewsAreValid && nameFieldIsValid } }
    var nameFieldIsValid = false { didSet { canSave = nameFieldIsValid && rubricViewsAreValid }}
    
    /// An array which will hold all the rubric views which have been created
    var rubricViews: [UIRubricView] {
        let views = self.stackView.arrangedSubviews
        var result = [UIRubricView]()
        for view in views { if let v = view as? UIRubricView { result.append(v) } }
        return result
    }
    /// Dict which holds any rubric views and that rubrics PK, which were intially added to the view due to editing a class
    var editingRubrics = [String: UIRubricView]()
    
    /// Any rubrics which were being edited and the user now wants to delete will be added to this array, stores the pk of the rubric to delete
    var rubricsToDelete = [String]()
    
    ///// Variables

    /// The class grade type, grabbed from the selection, tied to the view state
    var classGradeType: ClassGradeType = .weighted

    /// The class type, grabbed from the Picker
    var classType: ClassType!
    
    /// The semester, grabbed from the semesterField
    var semester: Semester!
    
    /// The current state the view is in, this doesn't change when editing a Class
    var viewState: ViewState = .inProgressWeighted
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If not on iPad where the view will be presented as a popover, dont have to worry about keyboard
        if !(UIDevice.current.userInterfaceIdiom == .pad) {
            // Setup keyboard notifications
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                                   name: .UIKeyboardDidShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                                   name: .UIKeyboardWillHide, object: nil)
        }
        
        //////// UI Setup //////

        // Theme setup
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
        self.typeSwitcher.superview?.backgroundColor = ApplicationTheme.shared.backgroundColor
        self.headerView1.backgroundColor = ApplicationTheme.shared.tableViewHeaderColor
        (self.headerView1.subviews.first as? UILabel)?.textColor = ApplicationTheme.shared.tableViewHeaderTextColor
        self.headerView2.backgroundColor = ApplicationTheme.shared.tableViewHeaderColor
        (self.headerView2.subviews.first as? UILabel)?.textColor = ApplicationTheme.shared.tableViewHeaderTextColor
        self.classNameField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.classNameField.textColor = ApplicationTheme.shared.mainTextColor()
        self.classNameField.titleTextColor = ApplicationTheme.shared.highlightColor
        self.classTypeView.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.classTypeField.textColor = ApplicationTheme.shared.mainTextColor()
        self.creditHoursField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.creditHoursField.textColor = ApplicationTheme.shared.mainTextColor()
        self.creditHoursField.titleTextColor = ApplicationTheme.shared.highlightColor
        self.semesterField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.semesterField.textColor = ApplicationTheme.shared.mainTextColor()
        self.gradeField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.gradeField.textColor = ApplicationTheme.shared.mainTextColor()

        updateNavBarForColorChange()
        
        // Customization for the fields
        let attrsForPrompt: [NSAttributedStringKey: Any] = [.foregroundColor: ApplicationTheme.shared.secondaryTextColor(),
                                                            .font: UIFont.preferredFont(forTextStyle: .body)]
        self.classNameField.titleText = "Class Name"
        self.classNameField.titleTextSpacing = 8.0
        self.classNameField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.classNameField.attributedPlaceholder = NSAttributedString(string: "Class Name", attributes: attrsForPrompt)
        self.classNameField.addTarget(self, action: #selector(updateSaveButton), for: .editingChanged)
        self.classNameField.autocapitalizationType = .words
        self.classNameField.returnKeyType = .next
        self.classNameField.delegate = self
        
        self.classTypeField.titleText = "Class type"
        self.classTypeField.titleTextSpacing = 8.0
        self.classTypeField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.classTypeField.toolbar.barTintColor = ApplicationTheme.shared.highlightColor
        self.classTypeField.toolbar.tintColor = .white
        self.classTypeField.toolbarLabel.text = "Select a class type"
        self.classTypeField.delegate = self
        
        self.creditHoursField.titleText = "Credit Hours"
        self.creditHoursField.titleTextSpacing = 8.0
        self.creditHoursField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.creditHoursField.attributedPlaceholder = NSAttributedString(string: "Credit Hours", attributes: attrsForPrompt)
        self.creditHoursField.configuration = NumberConfiguration(allowsSignedNumbers: false, range: 0.0...100.0)
        self.creditHoursField.fieldType = .number
        self.creditHoursField.returnKeyType = .next
        self.creditHoursField.keyboardType = .numbersAndPunctuation
        self.creditHoursField.delegate = self
        
        self.semesterField.titleText = "Semester"
        self.semesterField.titleTextSpacing = 8.0
        self.semesterField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.semesterField.toolbar.barTintColor = ApplicationTheme.shared.highlightColor
        self.semesterField.toolbar.tintColor = .white
        self.semesterField.toolbarLabel.text = "Select a semester"
        self.semesterField.handlesSettingTextManually = true
        self.semesterField.delegate = self
        
        self.gradeField.titleText = "Grade"
        self.gradeField.titleTextSpacing = 8.0
        self.gradeField.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.gradeField.toolbar.barTintColor = ApplicationTheme.shared.highlightColor
        self.gradeField.toolbar.tintColor = .white
        self.gradeField.toolbarLabel.text = "Select a grade"
        self.gradeField.delegate = self
        
        // Get student type from user defaults
        let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: kUserDefaultStudentType))
        
        // Hide the class type view if student is a college student
        self.classTypeView.isHidden = studentType == StudentType.college ? true : false
        
        // Set default values for slider and label
        let defaultCredits = studentType == StudentType.college ? "3.0" : "1.0"
        self.creditHoursField.text = defaultCredits
        
        // Set delegate and datsource for the picker fields
        self.classTypeField.pickerDelegate = self
        self.classTypeField.pickerDataSource = self
        self.semesterField.pickerDelegate = self
        self.semesterField.pickerDataSource = self
        self.gradeField.pickerDelegate = self
        self.gradeField.pickerDataSource = self
        
        // Disable save
        self.saveButton.isEnabled = false
        
        // If were editing a class then update the UI
        // Handle case of editing an in progress class
        if let editingClass = self.classObj {
            switch editingClass.classGradeType {
            case .weighted:
                // Set view state to in progress
                self.viewState = .inProgressWeighted
                self.prepareView(for: viewState, with: editingClass, isEditing: true)

            case .points:
                // Set view state to in progress
                self.viewState = .inProgressPoints
                self.prepareView(for: viewState, with: editingClass, isEditing: true)

            case .previous:
                // Set view state to previous
                self.viewState = .previous
                self.prepareView(for: viewState, with: editingClass, isEditing: true)
            }
        } else {
            // Not editing, set default class type
            self.classType = studentType == StudentType.college ? .college : .regular
            self.classTypeField.text = studentType == StudentType.college ? nil : "Regular"
            // Set a default semester
            setDefaultSemester()
            // Set a default grade
            let scale = self.realm.objects(GPAScale.self).first!
            let defaultGrade = scale.gpaRubrics[0].gradeLetter
            self.gradeField.text = defaultGrade
            // Prepare for add state
            self.prepareView(for: self.viewState, with: nil, isEditing: false)
            // Set a timer for the color
            colorTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self,
                                              selector: #selector(self.timerDidFinish(timer:)),
                                              userInfo: nil, repeats: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateNavBarForColorChange()
        self.updateSaveButton()
        self.toggleFieldTitles()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Invalidate color timer
        self.colorTimer?.invalidate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        let statusColor = self.colorForView.isLight() ? UIStatusBarStyle.default : UIStatusBarStyle.lightContent
        return statusColor
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    // MARK: UI Update Methods
    
    private func prepareView(for state: ViewState, with classObj: Class?, isEditing: Bool) {
        if isEditing {
            // Remove the switcher
            self.typeSwitcher.superview?.removeFromSuperview()
            self.typeSwitcher.removeFromSuperview()
        }
        
        // Update fields with edited classes attributes
        if let cls = classObj {
            self.navigationTitle.text = "Edit \(cls.name)"
            self.classNameField.text = cls.name
            self.classType = cls.classType
            self.classTypeField.text = cls.classType.name()
            self.creditHoursField.text = "\(cls.creditHours)"
            self.semester = cls.semester
            self.semesterField.text = "\(self.semester.term) \(self.semester.year)"
        }
        
        // Hide and show specific views
        switch state {
        case .inProgressWeighted:
            // Update fields specific to in progress class if available
            if let cls = classObj {
                updateRubricViews(for: cls)
            }
            
            // Initially we need to have at least one rubric view added to the view
            if rubricViews.isEmpty && self.classObj == nil { appendRubricView() }
            // The other views are hidden by default
            break

        case .inProgressPoints:
            // Remove rubric header view
            self.rubricHeaderView.removeFromSuperview()

        case .previous:
            // Update fields specific to previous class if available
            if let cls = classObj {
                self.gradeField.text = cls.grade?.gradeLetter
            }
            
            // Hide the rubric views, show the grade field
            self.gradeFieldContainerView.isHidden = false
            self.gradeField.isHidden = false
            self.gradeFieldContainerView.alpha = 1.0
            self.gradeField.alpha = 1.0
            // Remove rubric header view
            self.rubricHeaderView.removeFromSuperview()
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
    
    @IBAction func onNavbarTouched(_ gesture: UITapGestureRecognizer) {
        // Don't change color if touches are near the exit and save buttons.
        guard gesture.location(in: self.view).x > 80 && gesture.location(in: self.view).x < 290 else { return }
        // Change the navbar color
        colorForView = UIColor.randomPastel
        updateNavBarForColorChange()
    }
    
    @IBAction func onViewSwitchTapped(_ sender: UISegmentedControl) {
        // End any editing
        self.view.endEditing(true)
        
        self.viewState = sender.selectedSegmentIndex == 0 ? .inProgressWeighted :
                        sender.selectedSegmentIndex == 1 ? .inProgressPoints : .previous
        
        // Update the view
        switch self.viewState {

        case .inProgressWeighted:
            self.classGradeType = .weighted
            // Show all the views EXCEPT the grade selection view
            self.rubricHeaderView.isHidden = false
            for v in self.rubricViews { v.isHidden = false }
            
            UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeCubic, animations: { 
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.gradeFieldContainerView.alpha = 0.0
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: { 
                    self.rubricHeaderView.alpha = 1.0
                    self.rubricViews.forEach {  $0.alpha = 1.0 }
                })
                
            }, completion: { _ in
                self.gradeFieldContainerView.isHidden = true
                self.updateSaveButton()
            })

        case .inProgressPoints:
            self.classGradeType = .points
            // Hide rubric views and grade selection view
            UIView.animate(withDuration: 0.4, animations: {
                self.rubricHeaderView.alpha = 0.0
                self.rubricViews.forEach {  $0.alpha = 0.0 }
                self.gradeFieldContainerView.alpha = 0.0
            }, completion: { _ in
                self.rubricHeaderView.isHidden = true
                self.gradeFieldContainerView.isHidden = true
                self.rubricViews.forEach { $0.isHidden = true }
                self.updateSaveButton()
            })


        case .previous:
            self.classGradeType = .previous
            // Hide any rubric views, and show the grade selection view
            self.gradeFieldContainerView.isHidden = false
            UIView.animateKeyframes(withDuration: 0.4, delay: 0.0, options: .calculationModeCubic, animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.rubricHeaderView.alpha = 0.0
                    self.rubricViews.forEach {  $0.alpha = 0.0 }
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                    self.gradeFieldContainerView.alpha = 1.0
                })
                
            }, completion: { _ in
                self.rubricHeaderView.isHidden = true
                self.rubricViews.forEach { $0.isHidden = true }
                self.updateSaveButton()
            })
        }

    }

    /// Called whenever keyboard is shown, adjusts scroll view
    @objc func keyboardDidShow(notification: Notification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /// Called whenever keyboard is shown, adjusts scroll view
    @objc func keyboardWillHide(notification: Notification) {
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc func timerDidFinish(timer: Timer) {
        DispatchQueue.main.async {
            self.colorForView = UIColor.randomPastel
            self.updateNavBarForColorChange()
        }
    }
    
    // MARK: Save Methods
    
    @IBAction func onSave(_ sender: UIButton) {
        guard isSaveReady() else { return }
        // Switch on state, save the correct type of class
        switch self.viewState {
        case .inProgressWeighted, .inProgressPoints:
            guard let classObj = self.classObj else { saveNewInProgressClass(); return }
            saveChangesTo(inProgressClass: classObj)
        case .previous:
            guard let classObj = self.classObj else { saveNewPreviousClass(); return }
            saveChangesTo(previousClass: classObj)
        }
    }
    
    // Checks the fields, makes sure percents add up to 100%, etc, if not presents alert
    func isSaveReady() -> Bool {
        // Credit hours must be greater than 0
        if let creditHours = Double(self.creditHoursField.safeText), creditHours <= 0 {
            presentErrorAlert(title: "Unable to save", message: "Credit hours must be greater than zero.")
            return false
        }
        
        // If adding a previous class, this checking of rubrics can be skipped
        guard self.classGradeType == .weighted else { return true }
        
        // Want all rubric cells except the last one, since its always empty
        var views = rubricViews
        views.removeLast()
        
        // Keep track of total percent while looping
        var totalPercent: Double = 0.0
        
        for (index, view) in views.enumerated() {
            guard let percent = Double(view.weightField.safeText) else {
                presentErrorAlert(title: "Unable to save", message: "Some data is incorrect and cannot save, please check values and try again.")
                return false
            }
            
            if percent <= 0 {
                // Present alert warning user about zero percent
                // Construct title
                let title = NSAttributedString(string: "Can't Save 💔",
                                               attributes: [.font : UIFont.preferredFont(forTextStyle: .headline)])
                // Construct attributed message
                let invalidRowSubmessage = "row \(index + 1)"
                let attrsForSub: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.warning,
                                                                 .font: UIFont.preferredFont(forTextStyle: .body)]
                let attrsForMessage: [NSAttributedStringKey: Any] = [.foregroundColor: ApplicationTheme.shared.mainTextColor(in: .light),
                                                                     .font: UIFont.preferredFont(forTextStyle: .body)]
                let message = "Zero percentage is invalid in " + invalidRowSubmessage
                let messageAttributed = NSMutableAttributedString(string: message, attributes: attrsForMessage)
                messageAttributed.addAttributes(attrsForSub, range: (message as NSString).range(of: invalidRowSubmessage))
                
                self.present(alert: .message, withTitle: title, andMessage: messageAttributed)
                return false
            }
            
            totalPercent += percent
        }
        
        if round(totalPercent) != 100 {
            // Present alert telling user weights must add up to 100
            // Construct title
            let title = NSAttributedString(string: "Can't Save 💔",
                                           attributes: [.font : UIFont.preferredFont(forTextStyle: .headline)])
            // Construct the message
            let percentSubMessage = "\nCurrent total: \(totalPercent)%"
            let message = "Weights must add up to 100%." + percentSubMessage
            let attrsForMessage: [NSAttributedStringKey: Any] = [.foregroundColor : ApplicationTheme.shared.mainTextColor(in: .light),
                                                                 .font : UIFont.preferredFont(forTextStyle: .body)]
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
            rubrics.append(Rubric(name: rubricName, weight: rubricWeight))
        }
        
        // Create the semester
        let semester = Semester(term: self.semester.term, year: self.semester.year)
        
        let credits = Double(creditHoursField.safeText)!
        // Create the new class
        let newClass = Class(name: self.classNameField.safeText, gradeType: self.classGradeType, classType: self.classType,
                             creditHours: credits, semester: semester, rubrics: rubrics)
        newClass.colorData = colorForView.toData()
        
        // Add to realm
        DatabaseManager.shared.addObject(newClass)        
        
        // Dismiss controller
        self.dismiss(animated: true) {
            // Call listener
            self.listener?.classWasCreated(newClass)
        }
    }
    
    func saveNewPreviousClass() {
        let semester = Semester(term: self.semester.term, year: self.semester.year)
        let credits = Double(creditHoursField.safeText)!
        let newClass = Class(name: self.classNameField.safeText, classType: self.classType, creditHours: credits,
                             semester: semester, grade: Grade(gradeLetter: self.gradeField.safeText))
        newClass.colorData = colorForView.toData()
        
        // Write the new class to realm
        DatabaseManager.shared.addObject(newClass)
        
        // Dismiss controller
        self.dismiss(animated: true) {
            // Call listener
            self.listener?.classWasCreated(newClass)
        }
    }
    
    /// Saves the edits the user made to the object
    func saveChangesTo(inProgressClass classObj: Class) {
        // Lets save the changes made to the Class object, again can force unwrap since already checked for values

        let oldSemester = classObj.semester!.copy() as! Semester

        // Write changes to realm
        DatabaseManager.shared.write {
            classObj.name = self.classNameField.safeText
            classObj.classType = self.classType
            classObj.creditHours = Double(creditHoursField.safeText)!
            classObj.semester?.term = self.semester.term
            classObj.semester?.year = self.semester.year
            classObj.colorData = self.colorForView.toData()
        }
        
        // Delete any rubrics
        self.deleteRubrics()
        
        // The rubric views which will be added
        var rubricViews = self.rubricViews
        rubricViews.removeLast()
        
        // Loop through the rubric views and save any changes/add new rubrics
        for (pk, rubricView) in editingRubrics {
            let savedRubric = realm.object(ofType: Rubric.self, forPrimaryKey: pk)!
            DatabaseManager.shared.write {
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
            let newRubric = Rubric(name: name, weight: weight)
            DatabaseManager.shared.write {
                classObj.rubrics.append(newRubric)
            }
        }

        // Dismiss controller
        self.dismiss(animated: true) {
            // Call move listener if needed
            if oldSemester != classObj.semester {
                self.listener?.classSemesterWasUpdated(classObj, from: oldSemester, to: classObj.semester!)
            }
            // Call listener
            self.listener?.classWasUpdated(classObj)
        }
    }
    
    func saveChangesTo(previousClass classObj: Class) {

        let oldSemester = classObj.semester!.copy() as! Semester

        DatabaseManager.shared.write {
            classObj.name = self.classNameField.safeText
            classObj.classType = self.classType
            classObj.creditHours = Double(creditHoursField.safeText)!
            classObj.semester?.term = self.semester.term
            classObj.semester?.year = self.semester.year
            classObj.grade?.gradeLetter = self.gradeField.safeText
            classObj.colorData = self.colorForView.toData()
        }
        
        // Dismiss controller
        self.dismiss(animated: true) {
            // Call move listener if needed
            if oldSemester != classObj.semester {
                self.listener?.classSemesterWasUpdated(classObj, from: oldSemester, to: classObj.semester!)
            }
            // Call listener
            self.listener?.classWasUpdated(classObj)
        }
    }
    
    /// Deletes all rubrics inside of the rubricsToDelete array
    func deleteRubrics() {
        
        for pk in rubricsToDelete {
            // Get the rubric from realm using the pk
            let rubric = realm.object(ofType: Rubric.self, forPrimaryKey: pk)!
            // Get the assignments associated with this rubric
            let assignments = realm.objects(Assignment.self).filter("rubric = %@", rubric)
            // Write deletion to realm
            DatabaseManager.shared.deleteObjects(assignments)
            DatabaseManager.shared.deleteObjects([rubric])
            
            // Remove this rubric from the editing rubrics array
            editingRubrics.removeValue(forKey: pk)
        }
        // Done deleting no longer need this
        rubricsToDelete.removeAll()
    }
    
    // MARK: Helper Methods
    
    /// Toggles and shows field titles when appropriate
    private func toggleFieldTitles() {
        if self.classObj != nil {
            // Toggle name field since editing class
            self.classNameField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        }
        
        // Toggle all titles for fields if they have a default
        self.creditHoursField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        self.semesterField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        self.gradeField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
        self.classTypeField.setTitleVisible(titleVisible: true, animated: false, animationCompletion: nil)
    }
    
    private func updateNavBarForColorChange() {
        // Navigation view random color setup
        UIView.animate(withDuration: 0.15) {
            self.navigationView.backgroundColor = self.colorForView
            let visibleColor = self.colorForView.visibleTextColor(lightColor: .whiteText, darkColor: .darkText)
            self.cancelButton.tintColor = visibleColor
            self.saveButton.setTitleColor(visibleColor, for: .normal)
            let visibleDisabledColor = self.colorForView.visibleTextColor(lightColor: UIColor.frenchGray, darkColor: UIColor.gray)
            self.saveButton.setTitleColor(visibleDisabledColor, for: .disabled)
            self.navigationTitle.textColor = visibleColor
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
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
    
    @objc func updateSaveButton() {
        // Checks to see whether should enable save button
        let nameValid = self.classNameField.safeText.isValid()
    
        // Different case for selected states
        switch self.viewState {
        case .inProgressWeighted:
            var rubricsAreValid = false
            var validCount = 0
            for view in rubricViews { if view.isRubricValid { validCount += 1 } }
            rubricsAreValid = validCount != 1 && (validCount == rubricViews.count)
            
            self.saveButton.isEnabled = nameValid && rubricsAreValid
        case .inProgressPoints, .previous:
            self.saveButton.isEnabled = nameValid
            break
        }
    }

    /// Selects a semester that makes sense to the current date
    private func setDefaultSemester() {
        guard let terms = UserDefaults.standard.stringArray(forKey: kUserDefaultTerms) else { return }
        guard classObj == nil else { return }
        
        let month = Calendar.current.component(.month, from: Date())
        if (month == 12 || month == 1 || month == 2) && terms.index(of: "Winter") != nil {
            self.semester = Semester(term: "Winter", year: Semester.possibleYears[1])
        } else if (month == 3 || month == 4 || month == 5) && terms.index(of: "Spring") != nil {
            self.semester = Semester(term: "Spring", year: Semester.possibleYears[1])
        } else if (month == 6 || month == 7 || month == 8) && terms.index(of: "Summer") != nil {
            self.semester = Semester(term: "Summer", year: Semester.possibleYears[1])
        } else if (month == 9 || month == 10 || month == 11) && terms.index(of: "Fall") != nil {
            self.semester = Semester(term: "Fall", year: Semester.possibleYears[1])
        } else {
            self.semester = Semester(term: terms.first!, year: Semester.possibleYears[1])
        }
        
        self.semesterField.text = "\(self.semester.term) \(self.semester.year)"
    }
    
    /// Updates all rubric views and sets the fields to the editing class' attributes
    private func updateRubricViews(for classObj: Class) {
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
    
    /// Presents an alert when provided the specified alertType
    private func present(alert type: AlertType, withTitle title: NSAttributedString, andMessage message: NSAttributedString, options: [Any]? = nil) {
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
    
    deinit {
        // Remove any notifications
        NotificationCenter.default.removeObserver(self)
        // Remove timer
        colorTimer?.invalidate()
    }
}

// MARK: - Text Field Delegate
extension AddEditClassViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UISafeTextField else { return true }
        return field.shouldChangeTextAfterCheck(text: string)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.classNameField {
            self.classNameField.resignFirstResponder()
            if let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: kUserDefaultStudentType)),
                studentType == .highSchool {
                self.classTypeField.becomeFirstResponder()
            } else {
                self.creditHoursField.becomeFirstResponder()
            }
        } else if textField === self.creditHoursField {
            self.creditHoursField.resignFirstResponder()
            self.semesterField.becomeFirstResponder()
        }
        
        self.updateSaveButton()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === self.classTypeField {
            let selectedRow = self.classTypes.index(of: self.classType.name())!
            self.classTypeField.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            self.classTypeField.pickerDelegate?.didSelectPickerRow(selectedRow, in: 0, for: self.classTypeField)
        } else if textField === self.semesterField {
            let termRow = Semester.possibleTerms.index(of: self.semester.term)!
            let yearRow = Semester.possibleYears.index(of: self.semester.year)!
            self.semesterField.pickerView.selectRow(termRow, inComponent: 0, animated: false)
            self.semesterField.pickerDelegate?.didSelectPickerRow(termRow, in: 0, for: self.semesterField)
            self.semesterField.pickerView.selectRow(yearRow, inComponent: 1, animated: false)
            self.semesterField.pickerDelegate?.didSelectPickerRow(yearRow, in: 1, for: self.semesterField)
        } else if textField === self.gradeField {
            let selectedRow = self.gradeLetters.index(of: self.gradeField.safeText)!
            self.gradeField.pickerView.selectRow(selectedRow, inComponent: 0, animated: false)
            self.gradeField.pickerDelegate?.didSelectPickerRow(selectedRow, in: 0, for: self.gradeField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        updateSaveButton()
    }
}

// MARK: UIPickerField delegation & data source

extension AddEditClassViewController: UIPickerFieldDelegate, UIPickerFieldDataSource {
    /// The data for the class type picker
    private var classTypes: [String] {
        return ["Regular", "Honors", "AP", "IB", "College"]
    }

    /// The data for the grade picker
    private var gradeLetters: [String] {
        let scale = self.realm.objects(GPAScale.self)[0]
        return scale.gpaRubrics.map { $0.gradeLetter }
    }
    
    func numberOfComponents(in field: UIPickerField) -> Int {
        if field === self.semesterField { return 2 }
        else { return 1 }
    }
    
    func numberOfRows(in compononent: Int, for field: UIPickerField) -> Int {
        if field === self.semesterField {
            return compononent == 0 ? Semester.possibleTerms.count : Semester.possibleYears.count
        } else if field === self.classTypeField {
            return classTypes.count
        } else {
            return gradeLetters.count
        }
    }
    
    func titleForRow(_ row: Int, in component: Int, for field: UIPickerField) -> String? {
        if field === self.semesterField {
            return component == 0 ? Semester.possibleTerms[row] : String(Semester.possibleYears[row])
        } else if field === self.classTypeField {
            return classTypes[row]
        } else {
            return gradeLetters[row]
        }
    }
    
    func didSelectPickerRow(_ row: Int, in component: Int, for field: UIPickerField) {
        // Set class type
        if field === self.classTypeField {
            self.classType = ClassType(rawValue: row + 1)
        } else if field == self.semesterField {
            // If the picker field which was selected is the semester field, we need to do custom text setting
            if component == 0 {
                self.semesterField.text = self.semesterField.text?.replacingOccurrences(of: self.semester.term, with: Semester.possibleTerms[row])
                self.semester = Semester(term: Semester.possibleTerms[row], year: self.semester.year)
            } else {
                self.semesterField.text = self.semesterField.text?.replacingOccurrences(of: String(self.semester.year), with: String(Semester.possibleYears[row]))
                self.semester = Semester(term: self.semester.term, year: Semester.possibleYears[row])
            }
        }
    }
    
    func doneButtonTouched(for field: UIPickerField) {
        field.resignFirstResponder()
    }
}

// MARK: Rubric View Delegation
extension AddEditClassViewController: UIRubricViewDelegate {
    /// Notifies delgate that the rubrics valid state was updated
    internal func isRubricValidUpdated(forView view: UIRubricView) {
        updateSaveButton()
    }

    /// Notifies listener that the plus button was touched
    internal func plusButtonTouched(_ view: UIRubricView, withState state: UIRubricViewState?) {
        guard let `state` = state else { return }
    
        switch state {
        case .open:
            // User is about to close a rubric which was previously created, warn them what this means
            if let primaryKey = (editingRubrics as NSDictionary).allKeys(for: view).first as? String {
                let titleAttrs: [NSAttributedStringKey: Any] = [.font : UIFont.preferredFont(forTextStyle: .headline),
                                                                .foregroundColor : UIColor.warning]
                
                let title = NSAttributedString(string: "Remove Associated Assignments", attributes: titleAttrs)
                
                let messageAttrs: [NSAttributedStringKey: Any] = [.font : UIFont.preferredFont(forTextStyle: .body),
                                                                  .foregroundColor : ApplicationTheme.shared.mainTextColor(in: .light)]
                
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
