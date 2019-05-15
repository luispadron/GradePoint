//
//  GradePercentageTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class GradePercentageTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
