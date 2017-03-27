//
//  GPACalculatorViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing
import RealmSwift

class GPACalculatorViewController: UIViewController {
    
    // MARK: - Views/Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var progressContentView: UIView!
    @IBOutlet weak var progressRingView: UICircularProgressRingView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var customClassHeader: UIView!
    
    // MARK: - Properties
    /// The height for the GPA views
    let heightForGpaViews: CGFloat = 70.0
    /// The gpa views currently displayed on the view
    var gpaViews: [UIAddGPAView]  {
        get {
            var views = [UIAddGPAView]()
            for view in self.stackView.arrangedSubviews {
                if let gpaView = view as? UIAddGPAView { views.append(gpaView) }
            }
            return views
        }
    }

    /// MARK: - Overrides 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// UI Setup
        self.progressRingView.font = UIFont.systemFont(ofSize: 30)
        // Prepare the GPA Views
        prepareGpaViews()
        
        // Setup keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Now that were about to show, populate any gpa views
        let loadedClasses = try! Realm().objects(Class.self).filter({$0.assignments.count > 0})
        for (index, classObj) in loadedClasses.enumerated() {
            if index > self.gpaViews.count { break }
            populate(gpaView: self.gpaViews[index], withClass: classObj)
        }
        // Populate the custom classes that were saved from any previous calculations
        let customClasses = try! Realm().objects(GPAClass.self)
        for (index, gpaClass) in customClasses.enumerated() {
            let indexOfView = loadedClasses.count + index
            if indexOfView > gpaViews.count { break }
            self.populate(gpaView: self.gpaViews[indexOfView], withGpaClass: gpaClass)
        }
        
        // Always add an empty gpa view under custom classes header
        self.appendGpaView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Keyboard/ScrollView 
    
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

    
    // MARK: - Helper Methods
    
    func prepareGpaViews() {
        let realm = try! Realm()
        let loadedCount = realm.objects(Class.self).filter({ $0.assignments.count > 0 }).count
        
        // Add any of the loaded classes under the Loaded Classes header
        if loadedCount == 0 {
            // Remove the header for loaded classes since we dont have any
            self.stackView.removeArrangedSubview(self.stackView.arrangedSubviews[0])
        } else {
            for i in 1...loadedCount {
                let newView = UIAddGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGpaViews))
                newView.heightAnchor.constraint(equalToConstant: heightForGpaViews).isActive = true
                newView.delegate = self
                self.stackView.insertArrangedSubview(newView, at: i)
            }
        }
        
        // Add any of the saved custom classes under the Custom Classes header
        let customCount = realm.objects(GPAClass.self).count
        let indexOfHeader = self.stackView.arrangedSubviews.index(of: customClassHeader)!
        for i in 0..<customCount {
            let newView = UIAddGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGpaViews))
            newView.heightAnchor.constraint(equalToConstant: heightForGpaViews).isActive = true
            newView.delegate = self
            self.stackView.insertArrangedSubview(newView, at: indexOfHeader + i + 1)
        }
    }
    
    /// Populates a GPA view with the provided Class
    @discardableResult func populate(gpaView: UIAddGPAView, withClass classObj: Class) -> UIAddGPAView {
        // Update the fields with the class values
        gpaView.nameField.text = classObj.name
        gpaView.gradeField.text = classObj.letterGrade
        gpaView.creditsField.text = "\(classObj.creditHours)"
        gpaView.toDeleteState()
        
        // Since this shouldnt be edited we will remove that functionality now
        gpaView.toDisabled()
        
        return gpaView
    }
    
    /// Populates a GPA view with the provided GPAClass
    @discardableResult func populate(gpaView: UIAddGPAView, withGpaClass classObj: GPAClass) -> UIAddGPAView {
        // Update the fields with the class values
        gpaView.nameField.text = classObj.name
        gpaView.gradeField.text = classObj.gradeLetter
        gpaView.creditsField.text = "\(classObj.creditHours)"
        gpaView.toDeleteState()
        
        return gpaView
    }
    
    /// Adds a GPA view to the end of the stack view,  with animation
    @discardableResult func appendGpaView(withAnimation animated: Bool = true) -> UIAddGPAView {
        let newView = UIAddGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGpaViews))
        newView.heightAnchor.constraint(equalToConstant: heightForGpaViews).isActive = true
        newView.delegate = self
        
        // Add to the end of stackview
        self.stackView.addArrangedSubview(newView)
        
        // Animate if required
        if animated {
            newView.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
                newView.alpha = 1.0
            })
        }
        
        return newView
    }
    
    /// Removes a GPAView from the stack view, with animation
    func removeGpaView(view: UIAddGPAView) {
        view.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0.0
        }, completion: { _ in
            self.stackView.removeArrangedSubview(view)
        })
    }
    
    /// Returns whether all fields have been filled out and if were ready to calculate the GPA, also presents an alert notifying the user what to do
    func readyToCalculateGpa() -> Bool {
        var isReady = false
        
        for gpaView in gpaViews.filter({ $0.state == .delete || $0.state == .disabled }) {
            let hasCreditHours = Int(gpaView.creditsField.safeText) ?? -1 > 0
            let hasGrade = !gpaView.gradeField.safeText.isEmpty
            let hasName = gpaView.nameField.safeText.isValid()
            isReady = hasCreditHours && hasGrade && hasName
            // Present alert
            if !hasCreditHours {
                gpaView.creditsField.becomeFirstResponder()
                self.presentErrorAlert(title: "Unable To Calculate", message: "Make sure that all credit hour fields are filled out")
                break
            } else if !hasGrade {
                self.presentErrorAlert(title: "Unable To Calculate", message: "Make sure that all grade fields are filled out")
                break
            } else if !hasName {
                gpaView.nameField.becomeFirstResponder()
                self.presentErrorAlert(title: "Unable To Calculate", message: "Make sure that all name fields are filled out")
                break
            }
        }
        
        return isReady
    }
    
    /// Calculates the GPA using all the input from the UIAddGPAView
    func calculateGpa() {
        let scale = try! Realm().objects(GPAScale.self)[0]
        var totalPoints: Double = 0
        var totalCreditHours: Int = 0
        
        for gpaView in gpaViews.filter({ $0.state == .delete || $0.state == .disabled }) {
            let creditHours = Int(gpaView.creditsField.safeText)!
            totalCreditHours += creditHours
            let gradeMultiplier = scale.gpaRubrics.filter { $0.gradeLetter == gpaView.gradeField.safeText }[0].gradePoints
            totalPoints += Double(creditHours) * gradeMultiplier
        }
        
        let gpa = Double(totalPoints / Double(totalCreditHours)).roundedUpTo(2)
        self.progressRingView.setProgress(value: CGFloat(gpa), animationDuration: 1.5)
        
        // Finally save the gpa to realm
        saveCalculation(withGpa: gpa)
        
    }
    
    /// Saves the calculation to realm
    func saveCalculation(withGpa gpa: Double) {
        var gpaClasses = [GPAClass]()
        
        for gpaView in gpaViews.filter({ $0.state == .delete }) {
            let name = gpaView.nameField.safeText
            let grade = gpaView.gradeField.safeText
            let credits = Int(gpaView.creditsField.safeText)!
            let newGpaClass = GPAClass(name: name, gradeLetter: grade, creditHours: credits)
            gpaClasses.append(newGpaClass)
        }
        
        GPACalculation.createGPACalculation(withGpaClasses: gpaClasses, calculatedGpa: gpa)
    }
    
    // MARK: - Actions
    
    @IBAction func onExitButtonTap(_ sender: UIButton) {
        // Quickly animate the exit button rotation and dismiss
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }) { (finished) in
            if finished { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    
    @IBAction func onCalculateButtonTap(_ sender: UIButton) {
        guard readyToCalculateGpa() else { return }
        
        // Add the views if not already added
        if !stackView.arrangedSubviews.contains(self.progressContentView) {
            self.view.endEditing(true)
            // Animate the addition
            self.progressContentView.alpha = 0.0
            self.stackView.insertArrangedSubview(self.progressContentView, at: 0)
            UIView.animate(withDuration: 0.5, animations: { 
                self.progressContentView.alpha = 1.0
                
            }, completion: { _ in
                self.calculateGpa()
            })
        } else {
            // just calculate the GPA
            self.calculateGpa()
        }
        
        // Scroll up
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)
    }
    
}

/// MARK: GPA View Delegation
extension GPACalculatorViewController: UIAddGPAViewDelegate {
    func addButtonTouched(forView view: UIAddGPAView) {
        // Means new view must be created if state was of add else we need to remove this view
        switch view.state {
        case .add: // Current state is add, thus delete was tapped, remove this view
            self.removeGpaView(view: view)
        case .delete:
            self.appendGpaView()
        case .disabled:
            return
        }
    }
}
