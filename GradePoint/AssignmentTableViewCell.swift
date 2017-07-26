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


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateForSelection(selected)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        updateForSelection(highlighted)
    }

    // MARK: - Helper Methods

    func updateForSelection(_ selected: Bool) {

        switch UIColor.theme {
        case .dark: break
        case .light:
            nameLabel.textColor = selected ? UIColor.mainTextColor(in: .dark) : UIColor.mainTextColor(in: .light)
        }
    }
}
