//
//  ThemeSelectionTableViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 1/30/18.
//  Copyright © 2018 Luis Padron. All rights reserved.
//

import UIKit

class ThemeSelectionTableViewController: UITableViewController {

    private lazy var selectedThemeIndex: Int = {
        // Set default selected theme index, to current theme
        // Set initial theme for theme switcher
        let theme = UITheme(rawValue: UserDefaults.standard.integer(forKey: userDefaultTheme))
        return (theme?.rawValue ?? 1) - 1
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup UI
        self.navigationController?.navigationBar.barStyle = ApplicationTheme.shared.navigationBarStyle
        if #available(iOS 11.0, *) { self.navigationController?.navigationBar.prefersLargeTitles = true }
        // TableView customization
        // Remove seperator lines from empty cells
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor
        // Setup tableview estimates
        self.tableView.estimatedRowHeight = 44
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Update cell text color & add checkmark if selected
        cell.accessoryType = indexPath.row == self.selectedThemeIndex ? .checkmark : .none
        cell.tintColor = ApplicationTheme.shared.highlightColor
        guard let label = cell.contentView.subviews.first as? UILabel else { return }
        label.textColor = ApplicationTheme.shared.mainTextColor()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedThemeIndex == indexPath.row { return } // Do nothing
        self.selectedThemeIndex = indexPath.row
        // Update theme defaults
        guard let theme = UITheme(rawValue: self.selectedThemeIndex + 1) else { return }
        // Update theme
        UserDefaults.standard.set(self.selectedThemeIndex + 1, forKey: userDefaultTheme)
        ApplicationTheme.shared.theme = theme
        ApplicationTheme.shared.applyTheme()
        // Animate
        self.animateThemeChange()
        // Reload which will add/remove the checkmark
        self.tableView.reloadData()
    }

    // MARK: Helpers

    @objc private func updateUiForThemeChange() {
        // Since this view wont update until shown again, update nav and tab bar and cells right now

        self.navigationController?.navigationBar.barStyle = ApplicationTheme.shared.navigationBarStyle
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: ApplicationTheme.shared.mainTextColor()]
        self.navigationController?.navigationBar.tintColor = ApplicationTheme.shared.highlightColor
        self.navigationController?.navigationBar.barTintColor = ApplicationTheme.shared.lightBackgroundColor
        self.tabBarController?.tabBar.tintColor = ApplicationTheme.shared.highlightColor
        self.tabBarController?.tabBar.barTintColor = ApplicationTheme.shared.lightBackgroundColor
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
        self.tableView.separatorColor = ApplicationTheme.shared.tableViewSeperatorColor

        self.tableView.reloadData()

        // Post notification to allow any other view controllers that need to update their UI
        NotificationCenter.default.post(name: themeUpdatedNotification, object: nil)
    }

    private func animateThemeChange(duration: TimeInterval = 0.35) {
        // Create the scale animation

        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.duration = duration
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        // The animation layer which will be added ontop of this views current layer
        let animationLayer = CALayer()
        var radius = max(self.view.frame.width, self.view.frame.height)
        radius += radius * 0.40
        animationLayer.frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        animationLayer.position = self.view.center
        animationLayer.cornerRadius = radius/2
        animationLayer.opacity = 0.98

        let bgColor: UIColor
        switch ApplicationTheme.shared.theme {
        case .eco: bgColor = UIColor.ecoGreen
        default: bgColor = ApplicationTheme.shared.backgroundColor
        }
        animationLayer.backgroundColor = bgColor.cgColor

        // Set completion
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // Remove layer
            animationLayer.removeFromSuperlayer()
        }

        animationLayer.add(scaleAnimation, forKey: "pulse")
        // Finally add the layer to the top most view, this way it covers everything
        self.tabBarController?.view.layer.addSublayer(animationLayer)
        // Set timer to update UI
        Timer.scheduledTimer(timeInterval: duration * 0.80, target: self, selector: #selector(self.updateUiForThemeChange),
                             userInfo: nil, repeats: false)
        CATransaction.commit()
    }

}
