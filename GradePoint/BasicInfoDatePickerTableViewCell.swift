//
//  BasicInfoDatePickerTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 12/26/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoDatePickerTableViewCell: UITableViewCell {
    
    lazy var datePicker = UIDatePicker()
    
    // MARK: Overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
    }
    
    override func layoutSubviews() {
        self.layoutViews()
        super.layoutSubviews()
    }
    
    // MARK: Helper Methods
    
    private func initCell() {
        layoutViews()
        
        datePicker.datePickerMode = .date
        datePicker.setValue(UIColor.mainTextColor(), forKey: "textColor")
        
        self.addSubview(datePicker)
    }
    
    private func layoutViews() {
        datePicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
}
