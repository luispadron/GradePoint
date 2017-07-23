//
//  GenericLabelTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 1/13/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class GenericLabelTableViewCell: UITableViewCell {

    lazy var leftLabel = UILabel()
    lazy var rightLabel = UILabel()
    
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
        leftLabel.font = UIFont.systemFont(ofSize: 17)
        leftLabel.textColor = UIColor.frenchGray
        rightLabel.font = UIFont.systemFont(ofSize: 17)
        rightLabel.textColor = UIColor.mainTextColor()
        
        self.addSubview(leftLabel)
        self.addSubview(rightLabel)
    }
    
    private func layoutViews() {
        // Set frames for cells
        leftLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        let widthForRightLabel = self.contentView.frame.width - leftLabel.frame.width - (leftLabel.frame.origin.x + 100)
        rightLabel.frame = CGRect(x: leftLabel.frame.origin.x + 100, y: 0, width: widthForRightLabel, height: self.frame.height)
    }
    
    


}
