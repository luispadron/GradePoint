//
//  TextInputTableViewCell.swift
//  GradePoint
//
//  Created by Luis Padron on 1/14/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class TextInputTableViewCell: UITableViewCell {
    
    lazy var inputLabel = UILabel()
    var inputField = UITextField() {
        didSet {
            inputField.removeFromSuperview()
            inputLabel.removeFromSuperview()
            self.initCell()
        }
    }
    
    var promptText: String? {
        didSet {
            inputField.attributedPlaceholder = NSAttributedString(string: promptText ?? "",
                                                                 attributes: [NSForegroundColorAttributeName: promptColor ?? UIColor.mutedText])
        }
    }
    var promptColor: UIColor? {
        didSet {
            inputField.attributedPlaceholder = NSAttributedString(string: promptText ?? "",
                                                                 attributes: [NSForegroundColorAttributeName: promptColor ?? UIColor.mutedText])
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
    }
    
    // MARK: - Helper methods
    
    private func initCell() {
        
        self.layoutSubviews()
        
        // Init the input label
        inputLabel.textColor = UIColor.mutedText
        inputLabel.font = UIFont.systemFont(ofSize: 17)
        
        // Init the input field
        inputField.attributedPlaceholder = NSAttributedString(string: promptText ?? "", attributes: [NSForegroundColorAttributeName: promptColor ?? UIColor.mutedText])
        inputField.autocapitalizationType = .words
        inputField.font = UIFont.systemFont(ofSize: 17)
        inputField.textColor = UIColor.white
        inputField.returnKeyType = .done
        
        
        // Add as subviews
        self.addSubview(inputLabel)
        self.addSubview(inputField)
    }
    
    override func layoutSubviews() {
        inputLabel.frame = CGRect(x: 20, y: 0, width: 50, height: self.frame.height)
        let widthForTextField = self.contentView.frame.width - inputLabel.frame.width - (inputLabel.frame.origin.x + 100)
        inputField.frame = CGRect(x: inputLabel.frame.origin.x + 100, y: 0, width: widthForTextField, height: self.frame.height)
        super.layoutSubviews()
    }
    
}
