//
//  UIColorExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import GameKit

extension UIColor {
    
    // MARK: - Main Theme
    @nonobjc static let darkBg = UIColor(red:0.24, green:0.24, blue:0.27, alpha:1.0) /* #3c3c46 */
    @nonobjc static let lightBg = UIColor(red:0.26, green:0.27, blue:0.31, alpha:1.0) /* #43454f */
    @nonobjc static let highlight = UIColor(red: 111/255, green: 190/255, blue: 217/255, alpha: 1.0) /* #6fbed9 */
    @nonobjc static let unselected = UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1.0) /* #c7c7cd */
    @nonobjc static let mainText = UIColor.white
    @nonobjc static let textMuted = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0) /* #9b9b9b */
    
    // MARK: - TableView & Cells Theme
    
    @nonobjc static let tableViewHeader = UIColor(red: 100/255, green: 100/255, blue: 112/255, alpha: 1.0) /* #646470 */
    @nonobjc static let tableViewSeperator = UIColor(red: 78/255, green: 81/255, blue: 94/255, alpha: 1.0) /* #4e515e */
    
    // MARK - Random Color Generation
    
    /// Read only computed color - Pastel looking randomly generated color
    class var randomPastel: UIColor { return generateRandomColor(mixedWithColor: self.white, withRedModifier: nil, withGreenModifier: nil, withBlueModifier: nil) }

    /// Static function to generate random colors, can pass in a mix to get a different look and feel
    static func generateRandomColor(mixedWithColor mix: UIColor?, withRedModifier redM: Int?, withGreenModifier greenM: Int?, withBlueModifier blueM: Int?) -> UIColor {
        let redMod = redM ?? 0
        let greenMod = greenM ?? 0
        let blueMod = blueM ?? 0
        let random = GKMersenneTwisterRandomSource.init()
        var red = CGFloat(random.nextInt(upperBound: 256) + redMod)
        var green = CGFloat(random.nextInt(upperBound: 256) + greenMod)
        var blue = CGFloat(random.nextInt(upperBound: 256) + blueMod)
        
        // Mix the random colors with the color sent in, this allows for certain palletes
        if let mixColor = mix {
            let mixCI = CIColor(color: mixColor)
            let mixRed = mixCI.red * 255.0
            let mixGreen = mixCI.green * 255.0
            let mixBlue = mixCI.blue * 255.0
            
            // "Mix" the colors, take the average
            red = (red + mixRed) / 2
            green = (green + mixGreen) / 2
            blue = (blue + mixBlue) / 2
        }
        
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    
    // MARK: - Helpers
    
    /// Function which turns UIColor to NSData, for saving to realm
    func toData() -> Data { return NSKeyedArchiver.archivedData(withRootObject: self) }
    
}
