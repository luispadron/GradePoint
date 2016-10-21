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
    var rubricView: UIRubricView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initRubricView()
        contentView.isUserInteractionEnabled = false
        self.bringSubview(toFront: rubricView)
    }
    
    private func initRubricView() {
        rubricView = UIRubricView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(rubricView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        rubricView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        rubricView.setNeedsDisplay()
    }
}
