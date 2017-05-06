//
//  GPACalculatorViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing
import RealmSwift

class GPACalculatorViewController: UIViewController {

    // MARK: Views/Outlets
    
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var progressRingView: UICircularProgressRingView!
    @IBOutlet weak var weightSwitcher: UISegmentedControl!
    @IBOutlet var emptyView: UIView!
    
    
    // MARK: Properties
    
    /// The height for each GPA view
    let heightForGPAViews: CGFloat = 70.0
    /// The gpa views currently displayed on the view
    var gpaViews: [UIGPAView]  {
        get {
            var views = [UIGPAView]()
            for view in self.stackView.arrangedSubviews {
                if let gpaView = view as? UIGPAView { views.append(gpaView) }
            }
            return views
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        calculateButton.setTitleColor(UIColor.white, for: .normal)
        calculateButton.setTitleColor(UIColor.lightGray, for: .disabled)
        progressRingView.font = UIFont.systemFont(ofSize: 30)
        
        // Check to see if there any classes for which a calculation can be made
        let classes = try! Realm().objects(Class.self).filter { !$0.isClassInProgress || $0.assignments.count > 0 }
    
        if classes.count > 0 {
            // Prepare GPA Views, and load up all the required information
            prepareGPAViews()
        } else {
            // Add the empty view which displays a message to the user, and disable the calculate button
            stackView.removeFromSuperview()
            scrollView.removeFromSuperview()
            calculateButton.isEnabled = false
            self.view.addSubview(emptyView)
        }
        
        
        // Setup keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // If empty view is presenting set its size, else update the title labels on the Gpa views
        if self.view.subviews.contains(emptyView) {
            self.emptyView.frame = CGRect(x: 0, y: navBar.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - 50)
        } else {
            // Update each field in the UIGPAViews array to show
            for view in gpaViews {
                view.nameField.editingChanged()
                view.gradeField.editingChanged()
                view.creditsField.editingChanged()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Actions
    
    @IBAction func onWeightSwitcherValueChanged(_ sender: UISegmentedControl) {
        // Relculate GPA
        // Dispatch the calculation after 0.1 seconds since there seems to be a bug with UISegmenetedControl
        // Not sending the correct value exactly at the correct time, thus causing issues with the progress ring animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { 
            self.calculateGPA()
        }
    }
    
    @IBAction func onExitButtonPressed(_ sender: UIButton) {
        // Quickly animate the exit button rotation and dismiss
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }) { (finished) in
            if finished { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    
    @IBAction func onCalculateButtonPressed(_ sender: UIButton) {
        // Add the views if not already added
        if !stackView.arrangedSubviews.contains(progressRingView.superview!) {
            // End all editing
            self.view.endEditing(true)
            // Get the student type
            let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: UserPreferenceKeys.studentType.rawValue))
            // Add the progress ring to the stack view
            self.stackView.insertArrangedSubview(progressRingView.superview!, at: 0)
            // Animate the addition
            progressRingView.superview!.alpha = 0.0
            
            UIView.animate(withDuration: 0.5, animations: {
                self.progressRingView.superview!.alpha = 1.0
                // If the student is Highschool then show the type switcher
                if studentType == .highSchool {
                    self.weightSwitcher.isHidden = false
                    self.weightSwitcher.alpha = 1.0
                }
            }, completion: { _ in
                self.calculateGPA()
            })
        } else {
            // just calculate the GPA
            calculateGPA()
        }
        
        // Scroll up
        self.view.endEditing(true)
        scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)
    }
    
    
    /// Called whenever keyboard is shown, adjusts scroll view
    func keyboardDidShow(notification: Notification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /// Called whenever keyboard is shown, adjusts scroll view
    func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: Helper Methods
    
    /// Prepares all the GPA views and populates them with the values of their respective Class
    private func prepareGPAViews() {
        let realm = try! Realm()
        // Only want classes which are past classes, or in progress classes with more than one assignment
        let classes = realm.objects(Class.self).filter { !$0.isClassInProgress || $0.assignments.count > 0 }
        
        // Update each of the views with their appropriate class object
        for classObj in classes {
            // Create a GPA View and add it to the stack view
            let newView = UIGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGPAViews))
            newView.nameField.text = classObj.name
            newView.gradeField.text = classObj.grade!.gradeLetter
            newView.creditsField.text = "\(classObj.creditHours)"
            // Create height constraint and add to stackview
            newView.heightAnchor.constraint(equalToConstant: heightForGPAViews).isActive = true
            stackView.addArrangedSubview(newView)
        }
    }
    
    /// Calculates the GPA depending on the student type
    private func calculateGPA() {
        let scale = try! Realm().objects(GPAScale.self).first!
        let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: UserPreferenceKeys.studentType.rawValue))!
        let classes = try! Realm().objects(Class.self)
        var totalPoints: Double = 0.0
        var totalCreditHours: Int = 0

        /// Calculation of gpa closure block
        let calculate: (Bool) -> Double = { isWeighted in
            for (index, gpaView) in self.gpaViews.enumerated() {
                // The class associated with this view
                let associatedClass = classes[index]
                let creditHours = associatedClass.creditHours
                // The grade letter is grabbed from the view instead of the class since this can be changed
                let gradePoint = scale.gpaRubrics.filter { $0.gradeLetter == gpaView.gradeField.safeText }.first!.gradePoints
                // If calculation is weighted, then add up any additional points
                if isWeighted && studentType == .highSchool {
                    // Make sure to take into account credits, since weighted
                    totalPoints += (gradePoint + associatedClass.classType.additionalGradePoints()) * Double(creditHours)
                    totalCreditHours += creditHours
                } else if !isWeighted && studentType == .highSchool {
                    // Dont care about credits since unweighted & highschool student
                    totalPoints += gradePoint
                    totalCreditHours += 1
                } else {
                    // College student, take into account credits but dont add additional points per class type
                    totalPoints += Double(creditHours) * gradePoint
                    totalCreditHours += creditHours
                }
            }
            
            return Double(totalPoints / Double(totalCreditHours)).roundedUpTo(2)
        }
        
        switch studentType {
        case .college:
            // Get GPA
            let gpa = calculate(false)
            // Update progress ring
            progressRingView.setProgress(value: 0, animationDuration: 0) // Reset first
            // Set max value of ring to 4, since unweighted
            progressRingView.maxValue = 4.0
            // Set value to gpa
            progressRingView.setProgress(value: CGFloat(gpa), animationDuration: 1.5)
            // Save the calculated GPA
            saveCalculation(withGpa: gpa, weighted: false)
        case .highSchool:
            // Determine if we want weighted or unweighted
            if weightSwitcher.selectedSegmentIndex == 0 {
                // Get GPA
                let gpa = calculate(true)
                // Update progress ring
                progressRingView.setProgress(value: 0, animationDuration: 0) // Reset first
                // Set max value of ring to 5, since weighted
                progressRingView.maxValue = 5.0
                // Set value to gpa
                progressRingView.setProgress(value: CGFloat(gpa), animationDuration: 1.5)
                // Save the calculated GPA
                saveCalculation(withGpa: gpa, weighted: true)
            } else {
                // Get GPA
                let gpa = calculate(false)
                // Update progress ring
                progressRingView.setProgress(value: 0, animationDuration: 0) // Reset first
                // Set max value of ring to 4, since unweighted
                progressRingView.maxValue = 4.0
                // Set value to gpa
                progressRingView.setProgress(value: CGFloat(gpa), animationDuration: 1.5)
                //Save the calculated GPA
                saveCalculation(withGpa: gpa, weighted: false)
            }
        }
    }
    
    /// Saves the calculation to realm
    private func saveCalculation(withGpa gpa: Double, weighted: Bool) {
        let realm = try! Realm()
        try! realm.write {
            let newGPACalc = GPACalculation(calculatedGpa: gpa, date: Date(), weighted: weighted)
            realm.add(newGPACalc)
        }
    }

    
}
