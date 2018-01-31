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
}

/**
 The application theme property which manages the UITheme enum for this application.
 */
class ApplicationTheme {
    /// The theme for the application, used to determine which computed color to return
    lazy var theme: UITheme = {
        let defaults = UserDefaults.standard
        return UITheme(rawValue: defaults.integer(forKey: userDefaultTheme)) ?? .dark
    }()

    /// Singleton for the application
    public static let shared = ApplicationTheme()

    // MARK: Public properties

    var navigationBarStyle: UIBarStyle {
        switch self.theme {
        case .dark: return .black
        case .light: fallthrough
        case .eco: return .default
        }
    }

    var statusBarStyle: UIStatusBarStyle {
        switch self.theme {
        case .dark: return .lightContent
        case .light: fallthrough
        case .eco: return .default
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
        case .eco: fallthrough
        case .light:
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
            let attrs = [NSAttributedStringKey.foregroundColor.rawValue: self.mainTextColor(in: self.theme)]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attrs
        }
    }

    func mainTextColor(in content: UITheme? = nil) -> UIColor {
        let forContent = content != nil ? content! : self.theme
        switch forContent {
        case .dark: return .whiteText
        case .eco: fallthrough
        case .light: return .darkText
        }
    }

    func secondaryTextColor(in content: UITheme? = nil) -> UIColor {
        let forContent = content != nil ? content! : self.theme
        switch forContent {
        case .dark: return .frenchGray
        case .eco: fallthrough
        case .light: return .darkSilver
        }
    }

    // MARK: Computed Colors

    var highlightColor: UIColor {
        switch self.theme {
        case .dark: return .ocean
        case .light: return .blueWood
        case .eco: return .ecoGreen
        }
    }

    var backgroundColor: UIColor {
        switch self.theme {
        case .dark: return .tuna
        case .eco: fallthrough
        case .light: return .athensGray
        }
    }

    var lightBackgroundColor: UIColor {
        switch self.theme {
        case .dark: return .trout
        case .eco: fallthrough
        case .light: return .white
        }
    }

    var tableViewHeaderColor: UIColor {
        switch self.theme {
        case .dark: return .blueGray
        case .light: return .silverSand
        case .eco: return .ecoGreenHeader
        }
    }

    var tableViewHeaderTextColor: UIColor {
        switch self.theme {
        case .dark: return .frenchGray
        case .light: return .darkSilver
        case .eco: return .white
        }
    }

    var tableViewSeperatorColor: UIColor {
        switch self.theme {
        case .dark: return .midGray
        case .eco: fallthrough
        case .light: return .lightGray
        }
    }
}

