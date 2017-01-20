//
//  UIColorExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit


// Color extensions
extension UIColor {
    // MARK: - Main Theme
    static let navBar = UIColor(colorLiteralRed:0.24, green:0.24, blue:0.27, alpha:1.0) /* #3c3c46 */
    static let darkBg = UIColor(colorLiteralRed:0.24, green:0.24, blue:0.27, alpha:1.0) /* #3c3c46 */
    static let lightBg = UIColor(colorLiteralRed:0.26, green:0.27, blue:0.31, alpha:1.0) /* #43454f */
    static let highlight = UIColor(colorLiteralRed:0.66, green:0.87, blue:0.98, alpha:1.0) /* A9DEF9 */
    static let unselected = UIColor(colorLiteralRed: 199/255, green: 199/255, blue: 205/255, alpha: 1.0) /* #c7c7cd */
    static let lightText = UIColor(colorLiteralRed:0.98, green:0.98, blue:0.98, alpha:1.0) /* FAFAFA */
    static let darkText = UIColor(colorLiteralRed:0.21, green:0.21, blue:0.21, alpha:1.0) /* 363636 */
    static let mutedText = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1.0) /* #9b9b9b */
    
    // MARK: - TableView & Cells Theme
    
    static let tableViewHeader = UIColor(colorLiteralRed: 100/255, green: 100/255, blue: 112/255, alpha: 1.0) /* #646470 */
    static let tableViewSeperator = UIColor(colorLiteralRed: 78/255, green: 81/255, blue: 94/255, alpha: 1.0) /* #4e515e */
    
    // MARK: - Misc. Colors
    
    static let lapisLazuli = UIColor(colorLiteralRed:0.14, green:0.48, blue:0.63, alpha:1.0) /* 247BA0 */
    static let sunsetOrange = UIColor(colorLiteralRed:0.95, green:0.37, blue:0.36, alpha:1.0) /* F25F5C */
    static let mustard = UIColor(colorLiteralRed:1.00, green:0.88, blue:0.40, alpha:1.0) /* FFE066 */
}

// Random color generation extension
extension UIColor {
    // MARK - Random Color Generation
    
    /// Read only computed color - Pastel looking randomly generated color
    class var randomPastel: UIColor { return generateRandomColor(mixedWith: UIColor.white) }

    /// Static function to generate random colors, can pass in a mix to get a different look and feel
    static func generateRandomColor(mixedWith mix: UIColor?, redModifier redMod: Int? = nil, greenModifier greenMod: Int? = nil, blueModifier blueMod: Int? = nil) -> UIColor {
        
        var red = CGFloat(Int.random(withLowerBound: 1, andUpperBound: 255) + (redMod ?? 0))
        var green = CGFloat(Int.random(withLowerBound: 1, andUpperBound: 255) + (greenMod ?? 0))
        var blue = CGFloat(Int.random(withLowerBound: 1, andUpperBound: 255) + (blueMod ?? 0))
        
        guard let mixColor = mix else {
            return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
        }
        
        // Mix the random colors with the color sent in, this allows for certain palletes
        var mixRed: CGFloat = 0.0, mixBlue: CGFloat = 0.0, mixGreen: CGFloat = 0.0
        
        mixColor.getRed(&mixRed, green: &mixGreen, blue: &mixBlue, alpha: nil)
        mixRed *= 255.0
        mixGreen *= 255.0
        mixBlue *= 255.0
        
        // "Mix" the colors, take the average
        red = (red + mixRed) / 2
        green = (green + mixGreen) / 2
        blue = (blue + mixBlue) / 2
        
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    
    // MARK: - Helpers
    
    /// Function which turns UIColor to NSData, for saving to realm
    func toData() -> Data { return NSKeyedArchiver.archivedData(withRootObject: self) }
    
}
