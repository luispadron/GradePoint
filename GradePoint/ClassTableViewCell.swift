//
//  ClassTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    @IBOutlet weak var classRibbon: UIView!
    @IBOutlet weak var classTitleLabel: UILabel!
    @IBOutlet weak var classDetailLabel: UILabel!
    /// The color for the cells ribbon
    var ribbonColor: UIColor?
   
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set the rounded corners and color for the ribbon
        classRibbon.layer.cornerRadius = classRibbon.bounds.size.width / 2
        classRibbon.layer.masksToBounds = false
        // Set the label text colors
        classTitleLabel.textColor = UIColor.mainTextColor()
        classDetailLabel.textColor = UIColor.mutedText
    }
    
    override func prepareForReuse() {
        // Remove all refrences to old class obj, since the cell will be reused and new class will be assigned
        self.ribbonColor = nil
        classRibbon.backgroundColor = nil
        classTitleLabel.text = nil
        classDetailLabel.text = nil
        super.prepareForReuse()
    }

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
        // After selection occurs the cells "colorRibbon" dissapears since the UIView will become clear
        // reset the background color to the appropriate color
        self.classRibbon.backgroundColor = ribbonColor
        // Set white color for date text, so it looks better

        if selected { self.classDetailLabel.textColor = UIColor.lightText }
        else { self.classDetailLabel.textColor = UIColor.mutedText }
    }
}
