
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

        let defaults = UserDefaults.standard
        
        // Load default preferences into user defaults, in case these preference keys have not been set by user yet
        let prefsFile = Bundle.main.url(forResource: "DefaultPreferences", withExtension: "plist")!
        let prefsDict = NSDictionary(contentsOf: prefsFile)!
        defaults.register(defaults: prefsDict as! [String: Any])

        // Set the UI Theme for the saved theme key
        if let theme = UITheme(rawValue: defaults.integer(forKey: userDefaultTheme)) {
            setUITheme(for: theme)
        }
        
        // Figure out whether we have onboarded the user or not
        let hasOnboarded = defaults.bool(forKey: userDefaultOnboardingComplete)

        if let terms = defaults.stringArray(forKey: userDefaultTerms) {
            // TODO: Remove this code whenever old user base is migrated to version 2.0
            // Code in here due to the new re-ordering of default terms and there locations in version 2.0.
            if terms.count == 4 && terms[0] == "Spring" && terms[1] == "Summer" && terms[2] == "Fall" && terms[3] == "Winter" {
                defaults.set(["Winter", "Fall", "Summer", "Spring"], forKey: userDefaultTerms)
            }
        }
        
        if !hasOnboarded { self.presentOnboarding() }
        
        // Perform any required migrations
        DatabaseManager.setupRealm() {
            // App has launched and migrations finished, increase sessions
            self.incrementSessions()
        }

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

    /// Handles opening app via custom URL. Used with the Today extension of GradePoint.
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // If for some reason the user hasn't been onboarded then don't open the app yet
        if !UserDefaults.standard.bool(forKey: userDefaultOnboardingComplete) {
            return false
        }

        if url == emptyWidgetActionUrl {
            let count = DatabaseManager.shared.realm.objects(Class.self).count

            guard let splitNav = window?.rootViewController?.childViewControllers.first?.childViewControllers.first,
                let classesVC = splitNav.childViewControllers.first as? ClassesTableViewController else
            {
                print("WARNING: Tried to find ClassesTableViewController but was not able.")
                return false
            }

            if count == 0 {
                // Perform the add edit class segue
                classesVC.performSegue(withIdentifier: .addEditClass, sender: classesVC.navigationItem.rightBarButtonItem)
            } else {
                // Take user to gpa calculator view
                guard let tabBar = window?.rootViewController as? UITabBarController,
                    tabBar.childViewControllers.count > 1,
                    let calcsVC = tabBar.childViewControllers[1] as? CalculatorsViewController else
                {
                    print("WARNING: Tried to find ClassesTableViewController but was not able.")
                    return false
                }

                // Perform segue and show gpa calculator
                tabBar.selectedIndex = 1
                calcsVC.performSegue(withIdentifier: "presentGPACalculator", sender: nil)
            }
        }

        return url == emptyWidgetActionUrl || url == openUrl
    }

    /// Handles opening app via 3D touch quick action
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

        let cellBgView = UIView()

        switch theme {
        case .dark:
            UIApplication.shared.statusBarStyle = .lightContent
            cellBgView.backgroundColor = UIColor.highlight.darker(by: 25)
            UITableViewCell.appearance().selectedBackgroundView = cellBgView
            UITextField.appearance().keyboardAppearance = .dark
        case .light:
            UIApplication.shared.statusBarStyle = .default
            // Custom view for table view cell
            cellBgView.backgroundColor = UIColor.highlight
            UITableViewCell.appearance().selectedBackgroundView = cellBgView
            UITextField.appearance().keyboardAppearance = .default
        }

        // Customize main view appearances, more fine grained customizations is done at appropriate times throughout the code

        UINavigationBar.appearance().tintColor = UIColor.highlight
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.mainTextColor(in: theme)]

        UINavigationBar.appearance().barTintColor = UIColor.lightBackground

        UITabBar.appearance().tintColor = UIColor.highlight
        UITabBar.appearance().barTintColor = UIColor.lightBackground

        UITableView.appearance().backgroundColor = UIColor.background
        UITableViewCell.appearance().backgroundColor = UIColor.lightBackground

        UITextField.appearance().tintColor = UIColor.highlight
        UITextField.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = UIColor.mainTextColor(in: theme)

        UIPickerView.appearance().backgroundColor = UIColor.background

        UISegmentedControl.appearance().tintColor = UIColor.highlight

        UISlider.appearance().tintColor = UIColor.highlight

        UISwitch.appearance().tintColor = UIColor.highlight
        UISwitch.appearance().onTintColor = UIColor.highlight

        UISearchBar.appearance().tintColor = UIColor.highlight
        if #available(iOS 11.0, *) {
            let attrs = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.mainTextColor(in: theme)]
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
                DatabaseManager.setupRealm(completion: {
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

