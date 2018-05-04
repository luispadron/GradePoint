//
//  UIGradePercentageView.swift
//  GradePoint
//
//  Created by Luis Padron on 5/4/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

@IBDesignable
class UIGradePercentageView: UIView {

    // MARK: Members

    @IBInspectable public var gradeLetter: String = "A+" {
        didSet { self.label.text = self.gradeLetter }
    }

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
        self.backgroundColor = .clear
        self.addSubview(self.label)
    }

    // MARK: Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        self.label.sizeToFit()
        self.label.frame = CGRect(x: 16, y: self.center.y / 2, width: self.label.frame.width, height: self.label.frame.height)
    }

    // MARK: Api


    // MARK: Subviews

    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = ApplicationTheme.shared.mainTextColor()
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

}
