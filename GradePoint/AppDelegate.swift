//
//  AppDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Prints the realm path
        if TARGET_OS_SIMULATOR != 0 || TARGET_IPHONE_SIMULATOR != 0 { print("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)") }
        
        // Custom color for status bar
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Custom color for navigation bar
        UINavigationBar.appearance().tintColor = UIColor.highlight
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.mainText]
        UINavigationBar.appearance().barTintColor = UIColor.bars
        UINavigationBar.appearance().isTranslucent = false
        
        // Custom color for tab bar
        UITabBar.appearance().tintColor = UIColor.highlight
        UITabBar.appearance().barTintColor = UIColor.bars
        
        // Custom color for table view
        UITableView.appearance().backgroundColor = UIColor.background
        
        // Custom view for table view cell
        let bgView = UIView()
        bgView.backgroundColor = UIColor.highlight.darker(by: 25)
        UITableViewCell.appearance().selectedBackgroundView = bgView
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        // Change keyboard to dark version
        UITextField.appearance().keyboardAppearance = .dark
        UITextField.appearance().tintColor = UIColor.highlight
        
        // Change appearance for pickers
        UIPickerView.appearance().backgroundColor = UIColor.background
        
        // Change appearance for searchbars
        UISearchBar.appearance().tintColor = UIColor.highlight
        
        // Figure out whether we have onboarded the user or not
        let defaults = UserDefaults.standard
        let hasOnboarded = defaults.bool(forKey: UserDefaultKeys.onboardingComplete.rawValue)

        if defaults.stringArray(forKey: UserDefaultKeys.terms.rawValue) == nil {
            // Save a default string array of terms
            defaults.set(["Spring", "Summer", "Fall", "Winter"], forKey: UserDefaultKeys.terms.rawValue)
        }
        
        if !hasOnboarded { self.presentOnboarding() }
        
        return true
    }

    // MARK: Helper Methods
    
    private func presentOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let onboarding = storyboard.instantiateViewController(withIdentifier: "OnboardPageViewController") as! OnboardPageViewController
        self.window?.rootViewController = onboarding
    }
}

