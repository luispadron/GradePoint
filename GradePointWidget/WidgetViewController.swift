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

    @IBOutlet weak var ringContainerView: UIStackView!
    @IBOutlet weak var gpaRing: UICircularProgressRingView!
    @IBOutlet weak var classRing: UICircularProgressRingView!
    @IBOutlet weak var emptyLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 320, height: 120)
        // Setup realm
        DatabaseManager.setupRealm()
        
        // UI Setup
        gpaRing.ringStyle = .gradient
        gpaRing.gradientColors = [UIColor.pastelPurple.lighter(by: 40)!, UIColor.pastelPurple, UIColor.pastelPurple.darker(by: 30)!]
        gpaRing.innerCapStyle = .round
        gpaRing.outerRingColor = UIColor.white.withAlphaComponent(0.7)
        gpaRing.valueIndicator = ""
        gpaRing.showFloatingPoint = true
        gpaRing.decimalPlaces = 2
        gpaRing.fontColor = UIColor.black.withAlphaComponent(0.6)

        classRing.innerCapStyle = .round
        classRing.outerRingColor = UIColor.white.withAlphaComponent(0.7)
        classRing.innerRingColor = UIColor.clear
        classRing.showFloatingPoint = true
        classRing.decimalPlaces = 1
        classRing.ringStyle = .ontop
        classRing.fontColor = UIColor.black.withAlphaComponent(0.6)
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
        ringContainerView.isHidden = !showsClass && !showsGPA

        if showsClass {
            guard let assignment = realm.objects(Assignment.self).sorted(byKeyPath: "date", ascending: false).first,
                let recentClass = assignment.parentClass.first else {
                    print("Unable to get most recent class object.")
                    return
            }

            classRing.innerRingColor = recentClass.color
            classRing.setProgress(value: CGFloat(recentClass.grade!.score), animationDuration: 1.0)
        }

        if showsGPA {
            guard let recent = realm.objects(GPACalculation.self).first else {
                print("Unable to get most recent GPA calculation.")
                return
            }

            gpaRing.maxValue = recent.isWeighted ? 5.0 : 4.0
            gpaRing.setProgress(value: 0, animationDuration: 0)
            gpaRing.setProgress(value: CGFloat(recent.calculatedGpa), animationDuration: 1.0)
        }

        if #available(iOS 10.0, *) {
            // Something else here
        } else {
            // Change colors
        }
    }
}
