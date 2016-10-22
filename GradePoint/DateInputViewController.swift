//
//  DateInputViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class DateInputViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var datePicker: UIPickerView!
    var delegate: BasicInfoDateDelegate?
    
    var years = [Int]()
    let semesters = ["Fall", "Spring", "Summer", "Winter"]
    
    var selectedSemester = ""
    var selectedYear = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initPickerView()
        datePicker.selectRow(1, inComponent: 1, animated: false)
        selectedYear = years[1]
    }
    
    // MARK: - UIPickerView Delegates / Overrides
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return semesters.count
        case 1:
            return years.count
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedSemester = semesters[row]
            delegate?.pickerRowSelected(semester: selectedSemester, year: selectedYear)
        case 1:
            selectedYear = years[row]
            delegate?.pickerRowSelected(semester: selectedSemester, year: selectedYear)
        default:
            fatalError("Some how the UIPickerView component is not correct")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return semesters[row]
        case 1:
            return String(years[row])
        default:
            fatalError("Some how the UIPickerView component is not correct")
        }
        
        return nil
    }
    
    // MARK: - Helper Methods
    
    func initPickerView() {
        // Make it take the whole frame size
        datePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        datePicker.dataSource = self
        datePicker.delegate = self
        // Add as subview
        self.view.addSubview(datePicker)
        
        // Init the data for the picker view
        // Get the current year
        let date = Date()
        let calendar = NSCalendar.current
        let currentYear = calendar.component(.year, from: date)
        
        // For the current year, go one ahead and 30 behind.
        for i in 0...30 {
            years.append(currentYear - i)
        }
        // Finally one ahead
        years.insert(currentYear + 1, at: 0)
    }

}
