//
//  CalculatorsViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 3/26/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing
import RealmSwift

class CalculatorsViewController: UIViewController {

    @IBOutlet weak var gpaRing: UICircularProgressRingView!
    @IBOutlet weak var lastCalculationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set up the UI
        self.gpaRing.font = UIFont.systemFont(ofSize: 25)
        // Set the progress ring and label
        let attrs = [NSFontAttributeName: UIFont.italicSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.lightText.withAlphaComponent(0.6)]
        let savedCalc = try! Realm().objects(GPACalculation.self)
        
        if savedCalc.count > 0 {
            let calculation = savedCalc[0]
            gpaRing.setProgress(value: CGFloat(calculation.calculatedGpa), animationDuration: 0)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            lastCalculationLabel.attributedText = NSAttributedString(string: "Last calculated on: \(formatter.string(from: calculation.date))", attributes: attrs)
        } else {
            gpaRing.setProgress(value: 4.0, animationDuration: 0)
            lastCalculationLabel.attributedText = NSAttributedString(string: "Never calculated, calculate now", attributes: attrs)
        }
    }
}
