//
//  ClassPeekViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/18/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ClassPeekViewController: UIViewController {

    @IBOutlet weak var progressRing: UICircularProgressRing!
    
    var progress: CGFloat = 0.0
    var color: UIColor? = nil
    var indexPathForPeek: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let color = self.color {
            self.progressRing.innerRingColor = color
            self.progressRing.outerRingColor = ApplicationTheme.shared.backgroundColor.lighter(by: 20) ?? ApplicationTheme.shared.backgroundColor

            let gradientColors = [color.lighter(by: 40) ?? color, color, color.darker(by: 30) ?? color]
            self.progressRing.gradientOptions = UICircularRingGradientOptions(startPosition: .topRight,
                                                                              endPosition: .bottomLeft,
                                                                              colors: gradientColors,
                                                                              colorLocations: [0, 0.5, 1])
        }
        
        let roundingAmount = UserDefaults.standard.integer(forKey: kUserDefaultDecimalPlaces)
        self.progressRing.valueFormatter = UICircularProgressRingFormatter(showFloatingPoint: true,
                                                                           decimalPlaces: roundingAmount)
        self.progressRing.font = UIFont.systemFont(ofSize: 32)
        self.progressRing.startProgress(to: self.progress, duration: 1.5)
    }
    
    func setUI(for classObj: Class) {
        self.color = classObj.color
        self.progress = CGFloat(Class.calculateScore(in: classObj))
    }
    
}
