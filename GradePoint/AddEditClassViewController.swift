//
//  AddEditClassViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/22/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class AddEditClassViewController: UIViewController, UIScrollViewDelegate {

    // MARK: Properties
    
    let colorForView = UIColor.randomPastel
    
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
    
    var semester: Semester?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Setup
        self.navigationView.backgroundColor = colorForView
        let visibleColor = colorForView.visibleTextColor(lightColor: UIColor.lightText, darkColor: UIColor.darkText)
        self.cancelButton.tintColor = visibleColor
        self.saveButton.setTitleColor(visibleColor, for: .normal)
        self.navigationTitle.textColor = visibleColor

        semesterPickerView.isHidden = true
        semesterPickerView.alpha = 0.0
        semesterPickerConstraint.constant = 0.0
        semesterPickerView.delegate = self
        
        // Notify of nav bar color changes
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set status bar color
        let color = self.colorForView.isLight() ? UIStatusBarStyle.default : UIStatusBarStyle.lightContent
        UIApplication.shared.statusBarStyle = color
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Revert status bar changes
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // MARK: ScrollView Delegation
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrolling")
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
    
    @IBAction func onSave(_ sender: UIButton) {
        
    }
    
    @IBAction func onSemesterTap(_ sender: UITapGestureRecognizer) {
        let wasHidden = semesterPickerView.isHidden
        self.semesterPickerView.isHidden = false
        let toAlpha: CGFloat = wasHidden ? 1.0 : 0.0
        let toSize = wasHidden ? CGSize(width: self.semesterPickerView.frame.width, height: 120) : CGSize(width: self.semesterPickerView.frame.width, height: 0)
        
        UIView.animate(withDuration: 0.4, animations: {
            self.semesterPickerView.alpha = toAlpha
            self.semesterPickerView.frame.size = toSize
            self.semesterPickerConstraint.constant = toSize.height
            self.semesterLabel.textColor = wasHidden ? UIColor.highlight : UIColor.white
        }, completion: { finished in
            if finished { self.semesterPickerView.isHidden = !wasHidden }
        })
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
