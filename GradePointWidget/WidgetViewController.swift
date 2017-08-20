//
//  TodayViewController.swift
//  GradePointWidget
//
//  Created by Luis Padron on 8/20/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import NotificationCenter
import UICircularProgressRing
import RealmSwift

class WidgetViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var gpaRing: UICircularProgressRingView!
    @IBOutlet weak var classRing: UICircularProgressRingView!
    @IBOutlet weak var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 320, height: 120)
        // Setup realm
        DatabaseManager.setupRealm()
        // Update UI
        updateUI()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        updateUI()
        completionHandler(NCUpdateResult.newData)
    }

    func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return .zero
    }

    // MARK: Helpers

    private func updateUI() {
        // Figure out views to show
        let realm = DatabaseManager.shared.realm
        let showsGPA = realm.objects(GPACalculation.self).count > 0
        let showsClass = realm.objects(Assignment.self).count > 0

        gpaRing.superview?.isHidden = !showsGPA
        classRing.superview?.isHidden = !showsClass
        emptyLabel.isHidden = showsClass || showsGPA

        if #available(iOS 10.0, *) {
            // Something else here
        } else {
            // Change colors
        }
    }
}
