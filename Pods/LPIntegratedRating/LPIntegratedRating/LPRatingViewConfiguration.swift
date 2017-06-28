//
//  LPRatingViewConfiguration.swift
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
 # LPRatingViewConfiguration
 
 A configuration which an `LPRatingView` will use to configure it's UI.
 */
public struct LPRatingViewConfiguration {
    
    /**
     The title for the `LPRatingView`, will displayed at the top and centered
     */
    public let title: NSAttributedString
    
    /**
     The approval button title, this will be displayed on the right side of the view
     */
    public let approvalButtonTitle: NSAttributedString
    
    /**
     The rejection button title, this will be displayed on the left side of the view
     */
    public let rejectionButtonTitle: NSAttributedString
    
    /**
     The background color for the view
     
     ## Important:
     
     By default this will use a light purple color
     */
    public var backgroundColor: UIColor = UIColor.defaultColor
    
    /**
     The button color for the approval button
     
     ## Important:
     
     By default this will use `UIColor.white`
     */
    public var approvalButtonColor: UIColor = UIColor.white
    
    /**
     The button color for the rejection button
     
     ## Important:
     
     By default this will use a light purple color
     */
    public var rejectionButtonColor: UIColor = UIColor.defaultColor
    
    /// Creates a configuration with a title, approval title and rejection title
    public init(title: NSAttributedString, approvalButtonTitle: NSAttributedString, rejectionButtonTitle: NSAttributedString) {
        self.title = title
        self.approvalButtonTitle = approvalButtonTitle
        self.rejectionButtonTitle = rejectionButtonTitle
    }
}
