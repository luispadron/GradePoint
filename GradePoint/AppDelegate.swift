
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
    
    /// Returns the only AppInfo object stored in realm, if never created before, creates one and returns it
    public static var appInfo: AppInfo {
        get {
            let realm = DatabaseManager.shared.realm
            guard let info = realm.objects(AppInfo.self).first else {
                // Create an object, return it
                let newInfo = AppInfo()
                DatabaseManager.shared.createObject(AppInfo.self, value: newInfo, update: false)
                return newInfo
            }
            return info
        }
    }
    
    /// The initial root controler, before adding the onboarding controller as the root
    /// This is used when onboarding must be presented, because after onboarding is presented 
    /// we must fix the root view controllers to their orignal positions
    var initialRootController: UIViewController?
    
    /// The last time the app was active
    var lastTimeActive: Date?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // DEBUG setup
        if TARGET_OS_SIMULATOR != 0 || TARGET_IPHONE_SIMULATOR != 0 {
            print("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
            // Catches all exceptions and prints
            NSSetUncaughtExceptionHandler { (exception) in
                print(exception)
            }

            // For UITesting, handle any launch options
            prepareForUITesting()
        }

        let defaults = UserDefaults.standard

        // Set the UI Theme for the saved theme key
        if let theme = UITheme(rawValue: defaults.integer(forKey: themeKey)) {
            setUITheme(for: theme)
        } else {
            // Set default theme to dark
            defaults.set(UITheme.dark.rawValue, forKey: themeKey)
            setUITheme(for: .dark)
        }

        // Figure out whether we have onboarded the user or not
        let hasOnboarded = defaults.bool(forKey: UserDefaultKeys.onboardingComplete.rawValue)

        if defaults.stringArray(forKey: UserDefaultKeys.terms.rawValue) == nil {
            // Save a default string array of terms
            defaults.set(["Spring", "Summer", "Fall", "Winter"], forKey: UserDefaultKeys.terms.rawValue)
        }
        
        if !hasOnboarded { self.presentOnboarding() }
        
        // Perform any required migrations
        DatabaseManager.performMigrations() {
            // App has launched and migrations finished, increase sessions
            self.incrementSessions()
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Increase sessions if last session longer than two hours
        if let last = lastTimeActive {
            let secondsSince = abs(Int(Date().timeIntervalSince(last)))
            if secondsSince / 3600 >= 2 {
                self.incrementSessions()
            }
        }
        
        // Update last active time
        lastTimeActive = Date()
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void)
    {
        switch shortcutItem.quickActionId {
        case .addNewClass:
            guard let splitNav = window?.rootViewController?.childViewControllers.first?.childViewControllers.first,
                let classesVC = splitNav.childViewControllers.first as? ClassesTableViewController else
            {
                print("WARNING: Tried to find ClassesTableViewController but was not able.")
                return
            }
            
            // Perform the add edit class segue
            classesVC.performSegue(withIdentifier: .addEditClass, sender: classesVC.navigationItem.rightBarButtonItem)
            
        case .calculateGPA:
            guard let tabBar = window?.rootViewController as? UITabBarController,
                tabBar.childViewControllers.count > 1,
                let calcsVC = tabBar.childViewControllers[1] as? CalculatorsViewController else
            {
                print("WARNING: Tried to find ClassesTableViewController but was not able.")
                return
            }
            
            // Perform segue and show gpa calculator
            tabBar.selectedIndex = 1
            calcsVC.performSegue(withIdentifier: "presentGPACalculator", sender: nil)
            
        case .unknown:
            print("WARNING: Tried to handle an unknown quick action")
        }
        
    }

    // MARK: Helper Methods

    public func setUITheme(for theme: UITheme) {
        // TODO: Actually implement

        UIApplication.shared.statusBarStyle = .lightContent

        // Custom color for navigation bar
        UINavigationBar.appearance().tintColor = UIColor.highlight
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue:
            UIColor.mainTextColor(in: theme)]

        UINavigationBar.appearance().barTintColor = UIColor.lightBackground

        // Custom color for tab bar
        UITabBar.appearance().tintColor = UIColor.highlight
        UITabBar.appearance().barTintColor = UIColor.lightBackground

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
        if #available(iOS 11.0, *) {
            let attrs = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.white]
            UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = attrs
        }

    }
    
    /// Increments the appSessions count in the app info by 1
    private func incrementSessions() {
        DatabaseManager.shared.write {
            AppDelegate.appInfo.sessions += 1
        }
    }
    
    /// Present the onboarding to the user
    private func presentOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        let onboarding = storyboard.instantiateViewController(withIdentifier: "OnboardPageViewController") as! OnboardPageViewController
        self.initialRootController = self.window?.rootViewController
        self.window?.rootViewController = onboarding
    }
    
    /// Reset the root view controller to what it was initially
    func finishedPresentingOnboarding() {
        self.window?.rootViewController = initialRootController
    }
}

// MARK: Methods for UI Testing

extension AppDelegate {
    func prepareForUITesting() {
        var args = ProcessInfo.processInfo.arguments
        args.removeFirst()
        guard args.count > 0 else { return }

        print("App is launching with arguments: \(args)")

        for arg in args {
            switch arg {
            case "ClearState":
                DatabaseManager.performMigrations(completion: {
                    // Remove all objects from Realm and user defaults
                    DatabaseManager.shared.write {
                        DatabaseManager.shared.realm.deleteAll()
                    }
                })
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
            case "NoAnimations":
                UIView.setAnimationsEnabled(false)
            default:
                break
            }
        }
    }
}

