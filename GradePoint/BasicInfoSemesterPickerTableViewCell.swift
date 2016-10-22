//
//  BasicInfoSemesterPickerTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/22/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoSemesterPickerTableViewCell: UITableViewCell {
    
    var semesterPicker: UISemesterPickerView!
    
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
        semesterPicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        super.layoutSubviews()
    }
    
    
    // MARK: - Helper methods
    
    private func initCell() {
        semesterPicker = UISemesterPickerView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.addSubview(semesterPicker)
    }
}
