//
//  LPRatingCollectionViewCell.swift
//  LPIntegratedRating
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

open class LPRatingCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    open weak var delegate: LPRatingViewDelegate? {
        didSet {
            ratingView.delegate = self.delegate
        }
    }
    
    // MARK: Overrides
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initCell()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
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
    }
    
    // MARK: Subviews
    
    open lazy var ratingView: LPRatingView = {
        let view = LPRatingView(frame: .zero)
        return view
    }()
}
