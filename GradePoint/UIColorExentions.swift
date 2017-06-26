//
//  UIColorExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit


///  Static Color extensions
extension UIColor {
    
    // MARK: - App Colors
    
    static let background = UIColor(red: 0.208, green: 0.216, blue: 0.278, alpha: 1.00) // #353747
    static let lightBackground = UIColor(red: 0.290, green: 0.294, blue: 0.345, alpha: 1.00) // #4a4b58
    
    static let bars = UIColor(red: 0.263, green: 0.267, blue: 0.318, alpha: 1.00)
    
    static let tableViewHeader = UIColor(red: 0.365, green: 0.369, blue: 0.435, alpha: 1.00) // #5d5e6f
    static let tableViewSeperator = UIColor(red: 0.365, green: 0.369, blue: 0.435, alpha: 1.00) // #5d5e6f

    static let highlight = UIColor(colorLiteralRed:0.66, green:0.87, blue:0.98, alpha:1.0) /* A9DEF9 */
    static let mainText = UIColor(red: 0.980, green: 0.980, blue: 0.980, alpha: 1.00) // FAFAFA
    static let info = UIColor(colorLiteralRed:0.14, green:0.48, blue:0.63, alpha:1.0) /* #247BA0 */
    static let warning = UIColor(colorLiteralRed:0.95, green:0.37, blue:0.36, alpha:1.0) /* #F25F5C */
    static let favorite = UIColor(red: 0.808, green: 0.227, blue: 0.376, alpha: 1.00) /* ce3a60 */
    static let unselected = UIColor(colorLiteralRed: 199/255, green: 199/255, blue: 205/255, alpha: 1.0) /* #c7c7cd */
    static let mutedText = UIColor(colorLiteralRed: 155/255, green: 155/255, blue: 155/255, alpha: 1.0) /* #9b9b9b */
    static let accentGreen = UIColor(red:0.40, green:0.84, blue:0.71, alpha:1.0) /* #67D5B5 */
    static let accentPalePurple = UIColor(red: 0.647, green: 0.576, blue: 0.878, alpha: 1.00) /* #a593e0 */
}

/// Random color generation extension
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

/// Color Adjustment Extensions
extension UIColor {
    /// Returns a lighter color given percentage
    public func lighter(by percetange: CGFloat) -> UIColor? {
        return self.adjust(by: abs(percetange))
    }
    
    /// Returns a darker color given percentage
    public func darker(by percentage: CGFloat) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    /// Adjusts the color
    private func adjust(by percentage: CGFloat) -> UIColor? {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        
        return UIColor(red: min(r + percentage/100, 1.0), green: min(g + percentage/100, 1.0),
                       blue: min(b + percentage/100, 1.0), alpha: a)
    }
}

/// Text color extension

extension UIColor {
    public func isLight(threshold: CGFloat = 0.85) -> Bool {
        var white: CGFloat = 0
        self.getWhite(&white, alpha: nil)
        return white > threshold
    }
    
    /// Returns dark color if text should be black when placed ontop of background, or light color if text should be light over background
    public func visibleTextColor(lightColor: UIColor = UIColor.white, darkColor: UIColor = UIColor.black, threshold: CGFloat = 0.85) -> UIColor {
        return self.isLight(threshold: threshold) ? darkColor : lightColor
    }
    
}
