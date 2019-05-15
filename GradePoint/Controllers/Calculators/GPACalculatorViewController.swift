//
//  GPACalculatorViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation
import UIKit
import UICircularProgressRing
import RealmSwift
import GoogleMobileAds

class GPACalculatorViewController: UIViewController {

    // MARK: Views/Outlets
    
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var progressRingView: UICircularProgressRing!
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
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor

        self.headerView.backgroundColor = ApplicationTheme.shared.tableViewHeaderColor
        (self.headerView.subviews.first as? UILabel)?.textColor = ApplicationTheme.shared.tableViewHeaderTextColor

        self.progressRingView.fontColor = ApplicationTheme.shared.mainTextColor()
        self.progressRingView.font = UIFont.systemFont(ofSize: 30)
        let roundingAmount = UserDefaults.standard.integer(forKey: kUserDefaultDecimalPlaces)
        self.progressRingView.valueFormatter = UICircularProgressRingFormatter(valueIndicator: "",
                                                                               showFloatingPoint: true,
                                                                               decimalPlaces: roundingAmount)
        self.progressRingView.style = .ontop

        (self.emptyView.subviews.first as? UILabel)?.textColor = ApplicationTheme.shared.mainTextColor()

        self.weightSwitcher.tintColor = UIColor.pastelPurple

        self.calculateButton.setTitleColor(UIColor.white, for: .normal)
        self.calculateButton.setTitleColor(UIColor.lightGray, for: .disabled)
        
        // Check to see if there any classes for which a calculation can be made
        let classes = DatabaseManager.shared.realm.objects(Class.self).filter { !$0.isInProgress || $0.assignments.count > 0 }
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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

    @IBAction func emptyAddClassButtonTapped(_ sender: UIButton) {
        // Switch to add class view
        self.dismiss(animated: true) {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let tabController = delegate.window?.rootViewController as? UITabBarController
            // Select first tab
            tabController?.selectedIndex = 0
            let splitNav = tabController?.children.first?.children.first
            let classesViewController = splitNav?.children.first as? ClassesTableViewController
            // Add edit class segue
            classesViewController?.performSegue(withIdentifier: .addEditClass, sender: nil)
        }
    }

    
    @IBAction func onCalculateButtonPressed(_ sender: UIButton) {
        // Add the views if not already added
        if !self.stackView.arrangedSubviews.contains(self.progressRingView.superview!) {
            // End all editing
            self.view.endEditing(true)
            // Get the student type
            let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: kUserDefaultStudentType))
            // Add the progress ring to the stack view
            self.stackView.insertArrangedSubview(self.progressRingView.superview!, at: 0)
            // Animate the addition
            self.progressRingView.superview!.alpha = 0.0
            
            UIView.animate(withDuration: 0.4, animations: {
                self.progressRingView.superview!.alpha = 1.0
            }, completion: { _ in
                // If the student is Highschool then show the type switcher
                if studentType == .highSchool {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.weightSwitcher.isHidden = false
                        self.weightSwitcher.alpha = 1.0
                    }, completion: { _ in
                        self.calculateGPA()
                    })
                } else {
                    self.calculateGPA()
                }
            })
        } else {
            // just calculate the GPA
            self.calculateGPA()
        }
        
        // Scroll up
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)
    }

    @IBAction func didTapAddClass(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controllerId = "AddEditClassViewController"
        let controller = storyboard.instantiateViewController(withIdentifier: controllerId) as! AddEditClassViewController
        controller.modalPresentationStyle = .formSheet
        controller.preferredContentSize = CGSize(width: 300, height: 600)
        controller.listener = self

        self.present(controller, animated: true) {
            controller.typeSwitcher.selectedSegmentIndex = 2
            controller.onViewSwitchTapped(controller.typeSwitcher)
        }
    }

    
    /// Called whenever keyboard is shown, adjusts scroll view
    @objc func keyboardDidShow(notification: Notification) {
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        let ringSize = stackView.arrangedSubviews.contains(progressRingView.superview!) ? progressRingView.superview!.frame.height : 0
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.size.height + ringSize, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    /// Called whenever keyboard is shown, adjusts scroll view
    @objc func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    // MARK: Helper Methods
    
    /// Prepares all the GPA views and populates them with the values of their respective Class
    private func prepareGPAViews() {
        let realm = DatabaseManager.shared.realm
        // Only want classes which are previous classes, or in progress classes with more than one assignment
        let classes = realm.objects(Class.self).filter { !$0.isInProgress || $0.assignments.count > 0 }
        
        // Update each of the views with their appropriate class object
        classes.forEach { addGpaView(with: $0) }
    }
    
    /// Calculates the GPA depending on the student type
    private func calculateGPA() {
        let realm = DatabaseManager.shared.realm
        let studentType = StudentType(rawValue: UserDefaults.standard.integer(forKey: kUserDefaultStudentType))!
        let classes = realm.objects(Class.self)
        var totalPoints: Double = 0.0
        var totalCreditHours: Double = 0.0

        // Completion block for when progress ring is done animation
        let completion: UICircularProgressRing.ProgressCompletion = { [weak self] in
            guard let strongSelf = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                InterstitialAdController.shared.showAdIfCan(in: strongSelf)
            }
        }

        /// Calculation of gpa closure block
        let calculate: (Bool) -> Double? = { isWeighted in
            for (index, gpaView) in self.gpaViews.enumerated() {
                // The class associated with this view
                let associatedClass = classes[index]
                let creditHours = associatedClass.creditHours
                // The grade letter is grabbed from the view instead of the class since this can be changed
                let filteredRubrics = GPAScale.shared.gpaRubrics.filter { $0.gradeLetter == gpaView.gradeField.safeText }

                if filteredRubrics.isEmpty { return nil }

                let gradePoint = filteredRubrics.first!.gradePoints
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

            return Double(totalPoints / Double(totalCreditHours))
        }
        
        switch studentType {
        case .college:
            // Get GPA
            guard let gpa = calculate(true) else {
                self.presentErrorAlert(title: "Error calculating", message: "Make sure grades are valid and if you modified grade percentages, that they are correct")
                return
            }

            // Update progress ring
            self.progressRingView.resetProgress()
            // Set max value of ring to 4, since unweighted
            self.progressRingView.maxValue = 4.0
            // Set value to gpa
            self.progressRingView.startProgress(to: CGFloat(gpa), duration: 1.5, completion: completion)
            // Save the calculated GPA
            self.saveCalculation(withGpa: gpa, weighted: false)
        case .highSchool:
            // Determine if we want weighted or unweighted
            if weightSwitcher.selectedSegmentIndex == 0 {
                // Get GPA
                guard let gpa = calculate(true) else {
                    self.presentErrorAlert(title: "Error calculating", message: "Make sure grades are valid and if you modified grade percentages, that they are correct")
                    return
                }

                // Update progress ring
                self.progressRingView.resetProgress()
                // Set max value of ring to 5, since weighted
                self.progressRingView.maxValue = 5.0
                // Set value to gpa
                self.progressRingView.startProgress(to: CGFloat(gpa), duration: 1.5, completion: completion)
                // Save the calculated GPA
                self.saveCalculation(withGpa: gpa, weighted: true)
            } else {
                // Get GPA
                guard let gpa = calculate(false) else {
                    self.presentErrorAlert(title: "Error calculating", message: "Make sure grades are valid and if you modified grade percentages, that they are correct")
                    return
                }
                
                // Update progress ring
                self.progressRingView.resetProgress()
                // Set max value of ring to 4, since unweighted
                self.progressRingView.maxValue = 4.0
                // Set value to gpa
                self.progressRingView.startProgress(to: CGFloat(gpa), duration: 1.5, completion: completion)
                //Save the calculated GPA
                self.saveCalculation(withGpa: gpa, weighted: false)
            }
        }
    }
    
    /// Saves the calculation to realm
    private func saveCalculation(withGpa gpa: Double, weighted: Bool) {
        let newGPACalc = GPACalculation(calculatedGpa: gpa, date: Date(), weighted: weighted)
        DatabaseManager.shared.addObject(newGPACalc)
        

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if RatingManager.shouldPresentRating(appInfo: delegate.appInfo) {
            RatingManager.presentRating()
        }
    }

    /// adds a gpa view to the stackview
    @discardableResult
    private func addGpaView(with classObj: Class) -> UIGPAView {
        let newView = UIGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGPAViews))
        newView.nameField.text = classObj.name
        newView.gradeField.text = classObj.grade!.gradeLetter
        newView.creditsField.text = "\(classObj.creditHours)"
        // Create height constraint and add to stackview
        newView.heightAnchor.constraint(equalToConstant: heightForGPAViews).isActive = true
        stackView.addArrangedSubview(newView)
        return newView
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

extension GPACalculatorViewController: ClassChangesListener {
    func classWasCreated(_ classObj: Class) {
        let newView = self.addGpaView(with: classObj)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            newView.nameField.editingChanged()
            newView.gradeField.editingChanged()
            newView.creditsField.editingChanged()
        }

        self.calculateGPA()

        NotificationCenter.default.post(Notification(name: kRemoteClassChangeNotification))
    }

    func classSemesterWasUpdated(_ classObj: Class, from sem1: Semester, to sem2: Semester) { }

    func classWasUpdated(_ clasObj: Class) { }

}
