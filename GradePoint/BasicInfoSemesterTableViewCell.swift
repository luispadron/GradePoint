//
//  BasicInfoDateTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoSemesterTableViewCell: UITableViewCell {

    lazy var dateLabel = UILabel()
    lazy var dateInputLabel = UILabel()
    var delegate: SemesterPickerDelegate?
    
    // MARK: - Overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        dateLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        let widthForInputLabel = self.contentView.frame.width - dateLabel.frame.width - (dateLabel.frame.origin.x + 100)
        dateInputLabel.frame = CGRect(x: dateLabel.frame.origin.x + 100, y: 0, width: widthForInputLabel, height: self.frame.height)
        super.layoutSubviews()
    }
    
    // MARK: - Helper methods
    
    private func initCell() {
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
        dateInputLabel.isUserInteractionEnabled = true
        
        // Add gesture recognizer to label which will display a pop over to pick date inside AddClassTableViewController via delegation
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dateInputWasTapped))
        gesture.numberOfTapsRequired = 1
        dateInputLabel.addGestureRecognizer(gesture)
        
        // Add as subviews
        self.addSubview(dateLabel)
        self.addSubview(dateInputLabel)
    }
    
    // MARK: - Gesture recognizer
    func dateInputWasTapped() {
        delegate?.dateInputWasTapped(forCell: self)
    }

}
