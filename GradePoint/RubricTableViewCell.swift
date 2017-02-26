//
//  RubricTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class RubricTableViewCell: UITableViewCell {

    // Gets initialized in the cellForRow inside of AddEditClassTableViewController
    var rubricView: UIRubricView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
        layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
        layoutIfNeeded()
    }

    
    override func prepareForReuse() {
        layoutIfNeeded()
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        rubricView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        super.layoutSubviews()
    }
    
    func initCell() {
        rubricView = UIRubricView(frame: self.frame)
        self.addSubview(rubricView)
    }
    
}
