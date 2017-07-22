//
//  UIColor+Exentions.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

/// Colors for the app
extension UIColor {
    /// The theme for the application, used to determine which computed color to return
    class var theme: UITheme {
        let defaults = UserDefaults.standard
        return UITheme(rawValue: defaults.integer(forKey: themeKey)) ?? .dark
    }

    // MARK: Static Application Colors

    static let tuna = UIColor(red: 0.208, green: 0.216, blue: 0.278, alpha: 1.00) // #353747
    static let athensGray = UIColor(red: 0.937, green: 0.937, blue: 0.957, alpha: 1.00) // #efeff4
    static let trout = UIColor(red: 0.290, green: 0.294, blue: 0.345, alpha: 1.00) // #4a4b58
    static let frenchGray = UIColor(red: 0.825, green: 0.824, blue: 0.844, alpha: 1.00) // #d2d2d7
    static let blueGray = UIColor(red: 0.365, green: 0.369, blue: 0.435, alpha: 1.00) // #5d5e6f
    static let midGray = UIColor(red: 0.345, green: 0.349, blue: 0.408, alpha: 1.00) // #585968
    static let bluewood = UIColor(red: 0.212, green: 0.227, blue: 0.376, alpha: 1.00) /* #363a60 */
    static let ocean = UIColor(colorLiteralRed:0.66, green:0.87, blue:0.98, alpha:1.0) /* A9DEF9 */

    static let whiteText = UIColor(red: 0.980, green: 0.980, blue: 0.980, alpha: 1.00) // #fafafa
    static let mutedText = UIColor(red: 0.780, green: 0.780, blue: 0.804, alpha: 1.00) // #c7c7cd

    static let info = UIColor(colorLiteralRed:0.14, green:0.48, blue:0.63, alpha:1.0) /* #247BA0 */
    static let warning = UIColor(colorLiteralRed:0.95, green:0.37, blue:0.36, alpha:1.0) /* #F25F5C */
    static let favorite = UIColor(red: 0.808, green: 0.227, blue: 0.376, alpha: 1.00) /* ce3a60 */
    static let goldenYellow = UIColor(red: 0.965, green: 0.918, blue: 0.549, alpha: 1.00) /*f9d423*/

    static let pastelPurple = UIColor(red: 0.647, green: 0.576, blue: 0.878, alpha: 1.00) /* #a593e0 */

    // MARK: Computed Colors

    class var highlight: UIColor {
        switch theme {
        case .dark: return ocean
        case .light: return bluewood
        }
    }

    class var background: UIColor {
        switch theme {
        case .dark: return tuna
        case .light: return athensGray
        }
    }

    class var lightBackground: UIColor {
        switch theme {
        case .dark: return trout
        case .light: return white
        }
    }

    class var tableViewHeader: UIColor {
        switch theme {
        case .dark: return blueGray
        case .light: return frenchGray
        }
    }

    class var tableViewSeperator: UIColor {
        switch theme {
        case .dark: return midGray
        case .light: return lightGray
        }
    }

    class func mainTextColor(in content: UITheme = UIColor.theme) -> UIColor {
        switch theme {
        case .dark: return whiteText
        case .light: return darkText
        }
    }
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
