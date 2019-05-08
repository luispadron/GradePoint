
//
//  AppDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 10/12/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// The main window of the application
    var window: UIWindow?
    
    /// Returns the only AppInfo object stored in realm, if never created before, creates one and returns it
    lazy var appInfo: AppInfo = {
        let realm = DatabaseManager.shared.realm
        guard let info = realm.objects(AppInfo.self).first else {
            // Create an object, return it
            let newInfo = AppInfo()
            DatabaseManager.shared.createObject(AppInfo.self, value: newInfo, update: false)
            return newInfo
        }
        return info
    }()
    
    /// The initial root controler, before adding the onboarding controller as the root.
    /// This is used when onboarding must be presented, because after onboarding is presented 
    /// we must fix the root view controllers to their orignal positions
    var initialRootController: UIViewController?
    
    /// The last time the app was active
    var lastTimeActive: Date?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Create user defaults and load correct default preferences
        let defaults = UserDefaults.standard
        
        // Load default preferences into user defaults, in case these preference keys have not been set by user yet
        if let prefsFile = Bundle.main.url(forResource: "DefaultPreferences", withExtension: "plist"),
            let prefsDict = NSDictionary(contentsOf: prefsFile) as? [String: Any] {
            defaults.register(defaults: prefsDict)
        }

        // Load AdMob configuration
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // Set the UI Theme for the saved theme key
        if let theme = UITheme(rawValue: defaults.integer(forKey: kUserDefaultTheme)) {
            self.setUITheme(for: theme)
        }
        
        // Figure out whether we have onboarded the user or not
        let hasOnboarded = defaults.bool(forKey: kUserDefaultOnboardingComplete)

        // TODO: Remove this code whenever old user base is migrated to version 2.0
        // Code in here due to the new re-ordering of default terms and there locations in version 2.0.
        if let terms = defaults.stringArray(forKey: kUserDefaultTerms),
            terms.count == 4 && terms[0] == "Spring" &&
            terms[1] == "Summer" && terms[2] == "Fall" && terms[3] == "Winter" {
            defaults.set(["Winter", "Fall", "Summer", "Spring"], forKey: kUserDefaultTerms)
        }
        
        // Present onboarding if neccessary
        if !hasOnboarded { self.presentOnboarding() }
        
        // Perform any required database migrations
        DatabaseManager.setupRealm() {
            // App has launched and migrations finished, increase sessions
            self.incrementSessions()
        }

        // Add default grade percentage rubric for older users
        if hasOnboarded && DatabaseManager.shared.realm.objects(GradeRubric.self).count < 1 {
            GradeRubric.createRubric(type: GPAScale.shared.scaleType)
        }

        // DEBUG setup
        if TARGET_OS_SIMULATOR != 0 || TARGET_IPHONE_SIMULATOR != 0 {
            print("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)")
            // Catches all exceptions and prints
            NSSetUncaughtExceptionHandler { print($0) }
            // For UITesting, handle any launch options
            self.prepareForUITesting()
        }

        setupCrashlytics()

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
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // If for some reason the user hasn't been onboarded then don't open the app yet
        if !UserDefaults.standard.bool(forKey: kUserDefaultOnboardingComplete) {
            return false
        }

        if url == kEmptyWidgetActionURL {
            let count = DatabaseManager.shared.realm.objects(Class.self).count

            guard let splitNav = window?.rootViewController?.children.first?.children.first,
                let classesVC = splitNav.children.first as? ClassesTableViewController else
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
                    tabBar.children.count > 1,
                    let calcsVC = tabBar.children[1] as? CalculatorsViewController else
                {
                    print("WARNING: Tried to find ClassesTableViewController but was not able.")
                    return false
                }

                // Perform segue and show gpa calculator
                tabBar.selectedIndex = 1
                calcsVC.performSegue(withIdentifier: "presentGPACalculator", sender: nil)
            }
        }

        return url == kEmptyWidgetActionURL || url == kGradePointOpenURL
    }

    /// Handles opening app via 3D touch quick action
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.quickActionId {
        case .addNewClass:
            guard let splitNav = window?.rootViewController?.children.first?.children.first,
                let classesVC = splitNav.children.first as? ClassesTableViewController else
            {
                print("WARNING: Tried to find ClassesTableViewController but was not able.")
                return
            }
            
            // Perform the add edit class segue
            classesVC.performSegue(withIdentifier: .addEditClass, sender: classesVC.navigationItem.rightBarButtonItem)
            
        case .calculateGPA:
            guard let tabBar = window?.rootViewController as? UITabBarController,
                tabBar.children.count > 1,
                let calcsVC = tabBar.children[1] as? CalculatorsViewController else
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

    private func setUITheme(for theme: UITheme) {
        ApplicationTheme.shared.theme = theme
        ApplicationTheme.shared.applyTheme()
    }
    
    /// Increments the appSessions count in the app info by 1
    private func incrementSessions() {
        DatabaseManager.shared.write {
            appInfo.sessions += 1
        }
    }
    
    /// Present the onboarding to the user
    private func presentOnboarding() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let onboarding = storyboard.instantiateViewController(withIdentifier: "OnboardPageViewController")
            as? OnboardPageViewController else {
                return
        }

        self.initialRootController = self.window?.rootViewController
        self.window?.rootViewController = onboarding
    }
    
    /// Reset the root view controller to what it was initially
    func finishedPresentingOnboarding() {
        self.window?.rootViewController = self.initialRootController
    }

    private func setupCrashlytics() {
        // Setup fabric/crashlytics
        do {
            if let url = Bundle.main.url(forResource: "fabric.apikey", withExtension: nil) {
                let key = try String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
                Crashlytics.start(withAPIKey: key)
            }
        } catch {
            NSLog("Could not retrieve Crashlytics API key.")
        }
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

