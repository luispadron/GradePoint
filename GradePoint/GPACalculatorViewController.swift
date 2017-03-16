//
//  GPACalculatorViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing

class GPACalculatorViewController: UIViewController {
    
    // MARK: - Views/Outlets
    @IBOutlet weak var calculateButton: UIButton!
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
        
        // UI Setup
        
        
        // Add an initial gpa view
        if gpaViews.isEmpty { appendGpaView() }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.progressRingView.setProgress(value: 3.58, animationDuration: 5)
    }

    
    // MARK: - Helper Methods
    
    @discardableResult func appendGpaView() -> UIAddGPAView {
        let newView = UIAddGPAView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: heightForGpaViews))
        newView.heightAnchor.constraint(equalToConstant: heightForGpaViews).isActive = true
        self.stackView.addArrangedSubview(newView)
        return newView
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
    }
    
}

/// MARK: GPA View Delegation
extension GPACalculatorViewController: UIAddGPAViewDelegate {
    func addButtonTouched(forView view: UIAddGPAView) {
        
    }
}
