//
//  ClassCellHeaderView.swift
//  GradePoint
//
//  Created by Luis Padron on 12/1/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class ClassCellHeaderView: UIView {

    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
    
    private func initialize() {
        self.backgroundColor = ApplicationTheme.shared.tableViewHeaderColor
        self.addSubview(titleLabel)
        self.addSubview(scoreLabel)
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.frame = CGRect(x: 20, y: 0, width: self.frame.width * 0.75, height: self.frame.height)
        self.scoreLabel.sizeToFit()
        self.scoreLabel.frame = CGRect(x: self.bounds.width - self.scoreLabel.frame.width - 20 , y: 0,
                                       width: self.frame.width * 0.25, height: self.frame.height)
    }
    
    // MARK: Accessors
    
    public func setLabels(title: String, score: Double?) {
        self.titleLabel.text = title
        if let s = score {
            let roundingAmount = UserDefaults.standard.integer(forKey: userDefaultRoundingAmount)
            self.scoreLabel.text = String(format: "%.\(roundingAmount)f", s.roundedUpTo(roundingAmount))
        
        } else {
            self.scoreLabel.text = nil
        }
    }
    
    // MARK: Subviews
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = ApplicationTheme.shared.tableViewHeaderTextColor
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = ApplicationTheme.shared.tableViewHeaderTextColor
        return label
    }()
    
}
