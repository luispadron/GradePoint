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

        
        // Add an initial gpa view
        if gpaViews.isEmpty { appendGpaView() }
        
        // Setup keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
        let userInfo = notification.userInfo!
        var keyboardFrame: CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        self.scrollView.contentInset = .zero
        self.scrollView.scrollIndicatorInsets = .zero
    }

    
    // MARK: - Helper Methods
    
    @discardableResult func appendGpaView() -> UIAddGPAView {
        let newView = UIAddGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGpaViews))
        newView.heightAnchor.constraint(equalToConstant: heightForGpaViews).isActive = true
        newView.delegate = self
        
        // Animate the views
        newView.alpha = 0.0
        self.stackView.addArrangedSubview(newView)
        UIView.animate(withDuration: 0.3, animations: {
            newView.alpha = 1.0
        }, completion: { _ in
            // Add a default name to the the views name field
            newView.nameField.text = "Class \(self.gpaViews.count)"
            DispatchQueue.main.async { newView.nameField.editingChanged() }
        })
        
        return newView
    }
    
    func removeGpaView(view: UIAddGPAView) {
        view.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: {
            view.alpha = 0.0
        }, completion: { _ in
            self.stackView.removeArrangedSubview(view)
        })
    }
    
    func calculateGpa() {
        let scale = try! Realm().objects(GPAScale.self)[0]
        var totalPoints: Double = 0
        var totalCreditHours: Int = 0
        
        for gpaView in gpaViews.filter({ $0.state == .delete }) {
            if let creditHours = Int(gpaView.creditsField.safeText) {
                totalCreditHours += creditHours
                let gradeMultiplier = scale.gpaRubrics.filter { $0.gradeLetter == gpaView.gradeField.safeText }[0].gradePoints
                totalPoints += Double(creditHours) * gradeMultiplier
            } else {
                self.presentErrorAlert(title: "Can't Calculate GPA", message: "Please make sure all fields are filled out.")
                return
            }
        }
        
        // This shouldn't be possible, since textfield doesnt allow zero to be entered, however for a sanity check well do it...
        if totalCreditHours == 0 {
            self.presentErrorAlert(title: "Unable To Calculate", message: "Make sure that all values were entered correctly")
            return
        }
        
        self.progressRingView.setProgress(value: CGFloat(totalPoints / Double(totalCreditHours)), animationDuration: 1.5)
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
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)
        self.view.endEditing(true)
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
        }
    }
}
