//
//  BasicInfoDateTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoDateTableViewCell: UITableViewCell {

    lazy var dateLabel = UILabel()
    lazy var dateInputLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    // MARK: - Helper methods
    
    private func updateSubviews() {
        // Init the name label
        dateLabel.frame = CGRect(x: 20, y: 0, width: 60, height: self.frame.height)
        dateLabel.text = "Date"
        dateLabel.textColor = UIColor.textMuted
        dateLabel.font = UIFont.systemFont(ofSize: 17)
        
        // Init the text field
        let widthForInputLabel = self.contentView.frame.width - dateLabel.frame.width - (dateLabel.frame.origin.x + 100)
        dateInputLabel.frame = CGRect(x: dateLabel.frame.origin.x + 100, y: 0, width: widthForInputLabel, height: self.frame.height)
        dateInputLabel.font = UIFont.systemFont(ofSize: 17)
        dateInputLabel.text = "Fall 2016"
        dateInputLabel.textColor = UIColor.highlight
        
        // Add as subviews
        self.addSubview(dateLabel)
        self.addSubview(dateInputLabel)
    }
    
    override func layoutSubviews() {
        dateLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        let widthForInputLabel = self.contentView.frame.width - dateLabel.frame.width - (dateLabel.frame.origin.x + 100)
        dateInputLabel.frame = CGRect(x: dateLabel.frame.origin.x + 100, y: 0, width: widthForInputLabel, height: self.frame.height)
        super.layoutSubviews()
    }

}
