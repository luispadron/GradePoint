//
//  ApplicationTheme.swift
//  GradePoint
//
//  Created by Luis Padron on 7/21/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/**
 The UITheme enum which contains the possible themes for this application
 */
enum UITheme: Int {
    case dark = 1
    case light = 2
    case eco = 3
    case purple = 4
}

/**
 The application theme property which manages the UITheme enum for this application.
 */
class ApplicationTheme {
    /// The theme for the application, used to determine which computed color to return
    lazy var theme: UITheme = {
        let defaults = UserDefaults.standard
        return UITheme(rawValue: defaults.integer(forKey: kUserDefaultTheme)) ?? .dark
    }()

    /// Singleton for the application
    public static let shared = ApplicationTheme()

    // MARK: Public properties

    var navigationBarStyle: UIBarStyle {
        switch self.theme {
        case .dark: return .black
        default: return .default
        }
    }

    var statusBarStyle: UIStatusBarStyle {
        switch self.theme {
        case .dark: return .lightContent
        default: return .default
        }
    }

    // MARK: Public Methods

    /// Applies the theme by calling the required UIAplication.appearance methods needed
    func applyTheme() {
        let cellBgView = UIView()
        switch self.theme {
        case .dark:
            cellBgView.backgroundColor = self.highlightColor.darker(by: 25)
            UITableViewCell.appearance().selectedBackgroundView = cellBgView
            UITextField.appearance().keyboardAppearance = .dark
        default:
            // Custom view for table view cell
            cellBgView.backgroundColor = self.highlightColor
            UITableViewCell.appearance().selectedBackgroundView = cellBgView
            UITextField.appearance().keyboardAppearance = .default
        }

        // Customize main view appearances, more fine grained customizations is done at appropriate times throughout the code

        UINavigationBar.appearance().tintColor = self.highlightColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: self.mainTextColor(in: self.theme)]

        UINavigationBar.appearance().barTintColor = self.lightBackgroundColor

        UITabBar.appearance().tintColor = self.highlightColor
        UITabBar.appearance().barTintColor = self.lightBackgroundColor

        UITableView.appearance().backgroundColor = self.backgroundColor
        UITableViewCell.appearance().backgroundColor = self.lightBackgroundColor

        UITextField.appearance().tintColor = self.highlightColor
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = self.mainTextColor(in: theme)

        UIPickerView.appearance().backgroundColor = self.backgroundColor

        UISegmentedControl.appearance().tintColor = self.highlightColor

        UISlider.appearance().tintColor = self.highlightColor

        UISwitch.appearance().tintColor = self.highlightColor
        UISwitch.appearance().onTintColor = self.highlightColor

        UISearchBar.appearance().tintColor = self.highlightColor
        if #available(iOS 11.0, *) {
            let attrs = [NSAttributedString.Key.foregroundColor.rawValue: self.mainTextColor(in: self.theme)]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = convertToNSAttributedStringKeyDictionary(attrs)
        }
    }

    func mainTextColor(in content: UITheme? = nil) -> UIColor {
        let forContent = content != nil ? content! : self.theme
        switch forContent {
        case .dark: return .whiteText
        case .light: return .darkText
        case .eco: return .darkText
        case .purple: return .darkText
        }
    }

    func secondaryTextColor(in content: UITheme? = nil) -> UIColor {
        let forContent = content != nil ? content! : self.theme
        switch forContent {
        case .dark: return .frenchGray
        case .light: return .darkSilver
        case .eco: return .darkSilver
        case .purple: return .darkSilver
        }
    }

    // MARK: Computed Colors

    var highlightColor: UIColor {
        switch self.theme {
        case .dark: return .oceanBlue
        case .light: return .blueWood
        case .eco: return .ecoGreen
        case .purple: return .funPurple
        }
    }

    var backgroundColor: UIColor {
        switch self.theme {
        case .dark: return .tuna
        case .light: return .athensGray
        case .eco: return .athensGray
        case .purple: return .athensGray
        }
    }

    var lightBackgroundColor: UIColor {
        switch self.theme {
        case .dark: return .trout
        case .light: return .white
        case .eco: return .white
        case .purple: return .white
        }
    }

    var tableViewHeaderColor: UIColor {
        switch self.theme {
        case .dark: return .blueGray
        case .light: return .silverSand
        case .eco: return .ecoGreenHeader
        case .purple: return .silverSand
        }
    }

    var tableViewHeaderTextColor: UIColor {
        switch self.theme {
        case .dark: return .frenchGray
        case .light: return .darkSilver
        case .eco: return .white
        case .purple: return .darkSilver
        }
    }

    var tableViewSeperatorColor: UIColor {
        switch self.theme {
        case .dark: return .midGray
        case .light: return .lightGray
        case .eco: return .lightGray
        case .purple: return .lightGray
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.Key: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
