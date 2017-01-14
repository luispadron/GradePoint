//
//  BasicInfoRubricPickerTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 1/13/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoRubricPickerTableViewCell: UITableViewCell {

    lazy var rubricPicker = UIPickerView()
    
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
    
    private func initCell() {
        layoutViews()
        
        self.addSubview(rubricPicker)
    }
    
    private func layoutViews() {
        rubricPicker.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }

}
