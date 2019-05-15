//
//  UINavigationBar+StatusBarFix.swift
//  GradePoint
//
//  Created by Luis Padron on 1/31/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

/**
 Fixes issues with status bar appearance not being called showing properly
 */

extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    open override var childForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}

extension UITabBarController {
    open override var childForStatusBarStyle: UIViewController? {
        return self.children.first
    }

    open override var childForStatusBarHidden: UIViewController? {
        return self.children.first
    }
}

extension UISplitViewController {
    open override var childForStatusBarStyle: UIViewController? {
        return self.children.first
    }

    open override var childForStatusBarHidden: UIViewController? {
        return self.children.first
    }
}
