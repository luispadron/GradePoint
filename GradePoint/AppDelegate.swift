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

        // Checks for any required migrations
        checkForMigrations()
        
        // Custom color for status bar
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Custom color for navigation bar
        UINavigationBar.appearance().tintColor = UIColor.highlight
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.lightText]
        UINavigationBar.appearance().barTintColor = UIColor.background
        
        // Custom color for tab bar
        UITabBar.appearance().tintColor = UIColor.highlight
        UITabBar.appearance().barTintColor = UIColor.background
        
        // Custom color for table view
        UITableView.appearance().backgroundColor = UIColor.background
        
        // Custom view for table view cell
        let bgView = UIView()
        bgView.backgroundColor = UIColor.highlight
        UITableViewCell.appearance().selectedBackgroundView = bgView
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        // Change keyboard to dark version
        UITextField.appearance().keyboardAppearance = .dark
        
        // If no initial GPA Scale has been created then create that now, this will only be the case on first start up
        let realm = try! Realm()
        if realm.objects(GPAScale.self).count < 1 { GPAScale.createInitialScale() }
        
        // Figure out whether we have onboarded the user or not
        let defaults = UserDefaults.standard
        let hasOnboarded = defaults.bool(forKey: UserPreferenceKeys.onboardingComplete.rawValue)

        if !hasOnboarded { self.presentOnboarding() }
        
        return true
    }

    // MARK: Helper Methods
    
    private func presentOnboarding() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let onboarding = storyboard.instantiateViewController(withIdentifier: "OnboardPageViewController") as! OnboardPageViewController
        self.window?.rootViewController = onboarding
    }
    
    
    // TODO: REMOVE BEFORE RELEASE
    func checkForMigrations() {
        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    migration.enumerateObjects(ofType: Class.className(), { (oldObject, newObject) in
                        newObject!["creditHours"] = 3
                    })
                } else if oldSchemaVersion < 3 {
                    migration.enumerateObjects(ofType: GPAScale.className(), { (oldObject, newObject) in
                        newObject!["scaleType"] = GPAScaleType.plusScale.rawValue
                    })
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
}

