//
//  ClassTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    
    @IBOutlet weak var classRibbon: UIView!
    @IBOutlet weak var classTitleLabel: UILabel!
    @IBOutlet weak var classDateLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set the rounded corners and color for the ribbon
        classRibbon.layer.cornerRadius = classRibbon.bounds.size.width / 2
        classRibbon.layer.masksToBounds = false
        classRibbon.backgroundColor = UIColor.generateRandomColor(mixedWithColor: UIColor.white, withRedModifier: nil, withGreenModifier: nil, withBlueModifier: nil)
        // Set the label text colors
        classTitleLabel.textColor = UIColor.mainText
        classDateLabel.textColor = UIColor.textMuted
        // Set background color for the cell
        self.backgroundColor = UIColor.mainDark
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
