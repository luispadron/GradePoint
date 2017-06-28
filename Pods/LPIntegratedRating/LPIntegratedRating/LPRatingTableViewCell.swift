//
//  LPRatingTableViewCell.swift.swift
//  LPIntegratedRating
//
//  Copyright (c) 2017 Luis Padron
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is furnished
//  to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT
//  OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

/**
 # LPRatingTableViewCell
 
 A simple subclass of `UITableViewCell` which contains an `LPRatingView`.
 The rating view will fill up the cell's `contentView` thus to change the size make sure cell sizes are changed in
 the table view `heightForRow` delegate method.
 */
open class LPRatingTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    /// The delegate of the `LPRatingView` subview, this will just assign the delegate to the `ratingView` subview.
    open weak var delegate: LPRatingViewDelegate? {
        didSet {
            ratingView.delegate = self.delegate
        }
    }
    
    // MARK: Overrides
    
    /// Overriden
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    /// Overriden
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initCell()
    }
    
    /// Overriden
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initCell()
    }
    
    /// Overriden
    open override func layoutSubviews() {
        super.layoutSubviews()
        // Set full frame for view inside content view
        ratingView.frame = contentView.bounds
    }
    
    // MARK: Methods
    
    /// Initializes the cell by adding any subviews and removing cell selection
    private func initCell() {
        // Add view as subview
        if !self.contentView.subviews.contains(ratingView) {
            self.contentView.addSubview(ratingView)
        }
        self.selectionStyle = .none
    }
    
    // MARK: Subviews
    
    /// The rating view which will be added to the cell's `contentView`
    open lazy var ratingView: LPRatingView = {
        let view = LPRatingView(frame: .zero)
        return view
    }()
}
