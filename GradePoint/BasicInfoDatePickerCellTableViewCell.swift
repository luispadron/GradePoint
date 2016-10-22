//
//  BasicInfoDatePickerCellTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoDatePickerCellTableViewCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {

    var datePicker: UIPickerView!
    var years = [Int]()
    let semesters = ["Fall", "Spring", "Summer", "Winter"]
    var delegate: BasicInfoDateDelegate?
    var selectedSemester = ""
    var selectedYear = 0
    
    // MARK: - Overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
    }
    
    
    override func layoutSubviews() {
        datePicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
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
            delegate?.pickerRowSelected(semester: selectedSemester, year: selectedYear)
        case 1:
            selectedYear = years[row]
            delegate?.pickerRowSelected(semester: selectedSemester, year: selectedYear)
        default:
            fatalError("Some how the UIPickerView component is not correct")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch component {
        case 0:
             return NSAttributedString(string: semesters[row], attributes: [NSForegroundColorAttributeName: UIColor.white])
        case 1:
             return NSAttributedString(string: String(years[row]), attributes: [NSForegroundColorAttributeName: UIColor.white])
        default:
            fatalError("Some how the UIPickerView title for row passed in wrong range")
        }
        
        return nil
    }
    
    // MARK: - Helper methods
    
    private func initCell() {
        datePicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        datePicker.dataSource = self
        datePicker.delegate = self
        initDataForPickerView()
        self.addSubview(datePicker)
    }
    
    func initDataForPickerView() {
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
        
        // Select the current year
        datePicker.selectRow(1, inComponent: 1, animated: false)
        // Assign selected year to current year
        selectedYear = years[1]
    }
    
}
