//
//  AssignmentTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 12/5/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameLabel.textColor = UIColor.mainText
        scoreLabel.textColor = UIColor.mutedText
        dateLabel.textColor = UIColor.mutedText
        self.backgroundColor = UIColor.lightBackground
    }

}
