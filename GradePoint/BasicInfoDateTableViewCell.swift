//
//  BasicInfoDateTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 12/26/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoDateTableViewCell: UITableViewCell {

    lazy var dateHeaderLabel = UILabel()
    lazy var dateLabel = UILabel()
    
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
        self.layoutCells()
        super.layoutSubviews()
    }
    
    // MARK: Helper Methods
    
    private func initCell() {
        // Init header label
        dateHeaderLabel.text = "Date"
        dateHeaderLabel.textColor = UIColor.mutedText
        dateHeaderLabel.font = UIFont.systemFont(ofSize: 17)
        
        // Init date label, set the text to todays date
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: date)
        dateLabel.font = UIFont.systemFont(ofSize: 17)
        dateLabel.textColor = UIColor.lightText
        
        self.addSubview(dateHeaderLabel)
        self.addSubview(dateLabel)
    }
    
    private func layoutCells() {
        // Set frames for cells
        dateHeaderLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        let widthForDateLabel = self.contentView.frame.width - dateHeaderLabel.frame.width - (dateHeaderLabel.frame.origin.x + 100)
        dateLabel.frame = CGRect(x: dateHeaderLabel.frame.origin.x + 100, y: 0, width: widthForDateLabel, height: self.frame.height)
    }
    

}
