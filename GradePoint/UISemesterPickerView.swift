//
//  UISemesterPickerView.swift
//  GradePoint
//
//  Created by Luis Padron on 10/22/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class UISemesterPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var semesterPicker: UIPickerView!
    lazy var years = { UISemesterPickerView.createArrayOfYears() }()
    let semesters = ["Fall", "Spring", "Summer", "Winter"]
    var delegate: SemesterPickerDelegate?
    var selectedSemester: String!
    var selectedYear: Int!
    var titleColor = UIColor.white
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    override func layoutSubviews() {
        semesterPicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        super.layoutSubviews()
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
            delegate?.pickerRowSelected(term: selectedSemester, year: selectedYear)
        case 1:
            selectedYear = years[row]
            delegate?.pickerRowSelected(term: selectedSemester, year: selectedYear)
        default:
            fatalError("Some how the UIPickerView component is not correct")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
            return NSAttributedString(string: semesters[row], attributes: [NSForegroundColorAttributeName: titleColor])
        case 1:
            return NSAttributedString(string: String(years[row]), attributes: [NSForegroundColorAttributeName: titleColor])
        default:
            fatalError("Some how the UIPickerView title for row passed in wrong range")
        }
        
        return nil
    }
    
    // MARK: - Helper methods
    
    private func initView() {
        semesterPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        semesterPicker.dataSource = self
        semesterPicker.delegate = self
        initDataForPickerView()
        self.addSubview(semesterPicker)
    }
    
    func initDataForPickerView() {
        // Init the data for the picker view
        semesterPicker.selectRow(1, inComponent: 1, animated: false)
    
        // Init selected values
        selectedYear = years[1]
        selectedSemester = semesters[0]
    }
    
    static func createArrayOfYears() -> [Int] {
        var result = [Int]()
        let date = Date()
        let calendar = NSCalendar.current
        let currentYear = calendar.component(.year, from: date)
        
        // For the current year, go one ahead and 30 behind.
        for i in 0...30 {
            result.append(currentYear - i)
        }
        // Finally one ahead
        result.insert(currentYear + 1, at: 0)
        return result
    }


}
