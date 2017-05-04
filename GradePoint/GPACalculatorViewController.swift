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
    
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var progressRingView: UICircularProgressRingView!
    
    
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
        
        // Add progress ring view
        progressRingView.font = UIFont.systemFont(ofSize: 30)
        
        // Prepare GPA Views, and load up all the required information
        prepareGPAViews()
        
        // Setup keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // Update each field in the UIGPAViews array to show
        for view in gpaViews {
            view.nameField.editingChanged()
            view.gradeField.editingChanged()
            view.creditsField.editingChanged()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Actions
    
    
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
            self.view.endEditing(true)
            // Animate the addition
            progressRingView.superview!.alpha = 0.0
            self.stackView.insertArrangedSubview(progressRingView.superview!, at: 0)
            UIView.animate(withDuration: 0.5, animations: {
                self.progressRingView.superview!.alpha = 1.0
                
            }, completion: { _ in
                //                self.calculateGpa()
            })
        } else {
            // just calculate the GPA
            //            self.calculateGpa()
        }
        
        // Scroll up
        self.view.endEditing(true)
        self.scrollView.setContentOffset(CGPoint(x: 0,y: -self.scrollView.contentInset.top), animated: true)
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
    
    func prepareGPAViews() {
        let realm = try! Realm()
        let classes = realm.objects(Class.self)
        
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

    
}
