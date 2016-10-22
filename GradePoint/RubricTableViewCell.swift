//
//  RubricTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class RubricTableViewCell: UITableViewCell {

    // Get's initialized in the cellForRow inside of AddClassTableViewController
    @IBOutlet weak var rubricView: UIRubricView!
    
    override func prepareForReuse() {
        rubricView.updateViewForCellReuse()
        layoutIfNeeded()
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        rubricView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        super.layoutSubviews()
    }
    
}
