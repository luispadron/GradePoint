//
//  DateInputViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class IPadSemesterPickerViewController: UIViewController {
    
    var semesterPicker = UISemesterPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initPickerView()
    }
    
    // MARK: - Helper Methods
    
    func initPickerView() {
        // Make it take the whole frame size
        semesterPicker.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        semesterPicker.titleColor = UIColor.black
        // Add as subview
        self.view.addSubview(semesterPicker)
    }
}
