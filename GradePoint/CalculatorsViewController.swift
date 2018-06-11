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

    @IBOutlet weak var gpaCalculatorView: UIView!
    @IBOutlet weak var examCalculatorView: UIView!
    @IBOutlet weak var gpaRing: UICircularProgressRingView!
    @IBOutlet weak var lastCalculationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Set up the UI
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
        self.gpaRing.font = UIFont.systemFont(ofSize: self.gpaRing.frame.width/7.0)
        let roundingAmount = UserDefaults.standard.integer(forKey: kUserDefaultDecimalPlaces)
        self.gpaRing.decimalPlaces = roundingAmount
        
        // Add drop shadow to calculator views
        gpaCalculatorView.layer.cornerRadius = 10
        gpaCalculatorView.layer.shadowColor = UIColor.black.cgColor
        gpaCalculatorView.layer.shadowOffset = CGSize(width: 0, height: 0)
        gpaCalculatorView.layer.shadowOpacity = 0.4
        gpaCalculatorView.layer.shadowRadius = 5.0

        examCalculatorView.layer.cornerRadius = 10
        examCalculatorView.layer.shadowColor = UIColor.black.cgColor
        examCalculatorView.layer.shadowOffset = CGSize(width: 0, height: 0)
        examCalculatorView.layer.shadowOpacity = 0.4
        examCalculatorView.layer.shadowRadius = 5.0

        
        // Set the progress ring and label
        let attrs: [NSAttributedStringKey: Any] = [.font: UIFont.italicSystemFont(ofSize: 12),
                                                   .foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        let savedCalculations = DatabaseManager.shared.realm.objects(GPACalculation.self).sorted(byKeyPath: "date", ascending: true)
        
        if let lastCalculation = savedCalculations.last {
            // Set max value of progress ring depending on weighted or not
            let max: CGFloat = lastCalculation.isWeighted ? 5.0 : 4.0
            gpaRing.maxValue = max
            gpaRing.setProgress(to: 0, duration: 0)
            gpaRing.setProgress(to: CGFloat(lastCalculation.calculatedGpa), duration: 0)
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            lastCalculationLabel.attributedText = NSAttributedString(string: "Last calculated on: \(formatter.string(from: lastCalculation.date))", attributes: attrs)
        } else {
            gpaRing.setProgress(to: 0.0, duration: 0)
            lastCalculationLabel.attributedText = NSAttributedString(string: "Never calculated, calculate now", attributes: attrs)
        }
    }

}
