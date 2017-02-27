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
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var hasOnboardedUser: Bool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Prints the realm path
        if TARGET_OS_SIMULATOR != 0 || TARGET_IPHONE_SIMULATOR != 0 { print("Realm path: \(Realm.Configuration.defaultConfiguration.fileURL!)") }
        
        let splitViewController = self.window!.rootViewController!.childViewControllers.first as! UISplitViewController
        let detailNavController = splitViewController.viewControllers.last as? UINavigationController
        detailNavController?.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible
        
        
        // Custom color for status bar
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Custom color for navigation bar
        UINavigationBar.appearance().tintColor = UIColor.highlight
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.lightText]
        UINavigationBar.appearance().barTintColor = UIColor.navBar
        
        // Custom color for tab bar
        UITabBar.appearance().tintColor = UIColor.highlight
        UITabBar.appearance().barTintColor = UIColor.navBar
        
        // Custom color for table view
        UITableView.appearance().backgroundColor = UIColor.lightBg
        
        // Custom view for table view cell
        let bgView = UIView()
        bgView.backgroundColor = UIColor.highlight.darker(by: 20)
        UITableViewCell.appearance().selectedBackgroundView = bgView
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        
        // Change keyboard to dark version
        UITextField.appearance().keyboardAppearance = .dark
        
        // Figure out whether we have onboarded the user or not
        let defaults = UserDefaults.standard
        self.hasOnboardedUser = defaults.bool(forKey: UserPreferenceKeys.onboardingComplete.rawValue)
    
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Split view

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        guard let detailNavController = secondaryViewController as? UINavigationController else { return false }
        guard let detailController = detailNavController.topViewController as? ClassDetailTableViewController else { return false }
        if detailController.classObj == nil { return true }
        return false
    }

}
