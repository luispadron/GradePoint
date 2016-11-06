//
//  BasicInformationTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class BasicInfoNameTableViewCell: UITableViewCell {

    lazy var nameLabel = UILabel()
    lazy var classNameField = UITextField()
    
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
    
    
    // MARK: - Helper methods
    
    private func initCell() {
        // Init the name label
        nameLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        nameLabel.text = "Name"
        nameLabel.textColor = UIColor.mutedText
        nameLabel.font = UIFont.systemFont(ofSize: 17)
        
        // Init the text field
        let widthForTextField = self.contentView.frame.width - nameLabel.frame.width - (nameLabel.frame.origin.x + 100)
        classNameField.frame = CGRect(x: nameLabel.frame.origin.x + 100, y: 0, width: widthForTextField, height: self.frame.height)
        classNameField.attributedPlaceholder = NSAttributedString(string: "Class Name", attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        classNameField.autocapitalizationType = .words
        classNameField.font = UIFont.systemFont(ofSize: 17)
        classNameField.textColor = UIColor.white
        classNameField.returnKeyType = .done
        
        
        // Add as subviews
        self.addSubview(nameLabel)
        self.addSubview(classNameField)
    }
    
    override func layoutSubviews() {
        nameLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        let widthForTextField = self.contentView.frame.width - nameLabel.frame.width - (nameLabel.frame.origin.x + 100)
        classNameField.frame = CGRect(x: nameLabel.frame.origin.x + 100, y: 0, width: widthForTextField, height: self.frame.height)
        super.layoutSubviews()
    }

}
