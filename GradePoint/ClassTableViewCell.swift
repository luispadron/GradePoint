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
    @IBOutlet weak var classDateLabel: UILabel!
    
    /// The class associated with the cell
    var classObj: Class? {
        didSet {
            updateUI()
        }
    }
   
    // MARK: - Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // Set the rounded corners and color for the ribbon
        classRibbon.layer.cornerRadius = classRibbon.bounds.size.width / 2
        classRibbon.layer.masksToBounds = false
        // Set the label text colors
        classTitleLabel.textColor = UIColor.mainText
        classDateLabel.textColor = UIColor.textMuted
        // Set background color for the cell
        self.backgroundColor = UIColor.darkBg
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        guard let classItem = classObj else {
            return
        }
        // After selection occurs the cells "colorRibbon" dissapears since the UIView will become clear
        // reset the background color to the appropriate color
        self.classRibbon.backgroundColor = NSKeyedUnarchiver.unarchiveObject(with: classItem.colorData) as? UIColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        guard let classItem = classObj else {
            return
        }
        // After selection occurs the cells "colorRibbon" dissapears since the UIView will become clear
        // reset the background color to the appropriate color
        self.classRibbon.backgroundColor = NSKeyedUnarchiver.unarchiveObject(with: classItem.colorData) as? UIColor
    }
    
    // MARK: - Helper Methods
    func updateUI() {
        guard let classItem = classObj else {
            fatalError("classObj was not set for this class cell")
        }
        // Set the approritate ui types to their fields
        self.classTitleLabel.text = classItem.name
        self.classDateLabel.text = "\(classItem.semester!.term) \(classItem.semester!.year)"
        self.classRibbon.backgroundColor = NSKeyedUnarchiver.unarchiveObject(with: classItem.colorData) as? UIColor
    }
}
