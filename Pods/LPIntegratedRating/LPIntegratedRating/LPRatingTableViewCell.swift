//
//  UITableViewCell+Rating.swift
//  LPIntegratedRating
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class LPRatingTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    open weak var delegate: LPRatingViewDelegate? {
        didSet {
            ratingView.delegate = self.delegate
        }
    }
    
    // MARK: Overrides
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layoutSubviews()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Set full frame for view inside content view
        ratingView.frame = contentView.bounds
    }
    
    // MARK: Methods
    
    private func initCell() {
        // Add view as subview
        self.contentView.addSubview(ratingView)
        self.selectionStyle = .none
    }
    
    // MARK: Subviews
    
    open lazy var ratingView: LPRatingView = {
        let view = LPRatingView(frame: .zero)
        return view
    }()
}
