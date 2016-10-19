//
//  RubricTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/15/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class RubricTableViewCell: UITableViewCell {

    @IBOutlet weak var rubricView: UIRubricView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        rubricView.backgroundColor = UIColor.darkBg
        rubricView.plusColor = UIColor.highlight
        rubricView.radius = 15.0
        
    }
}
