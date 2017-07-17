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

    @IBOutlet weak var progressRing: UICircularProgressRingView!
    
    var progress: CGFloat = 0.0
    var color: UIColor? = nil
    var indexPathForPeek: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let color = self.color {
            self.progressRing.ringStyle = .gradient
            self.progressRing.innerRingColor = color
            self.progressRing.outerRingColor = UIColor.background.lighter(by: 20) ?? UIColor.background
            self.progressRing.gradientColors = [color.lighter(by: 40) ?? color,
                                                color,
                                                color.darker(by: 30) ?? color]
        }
        self.progressRing.font = UIFont.systemFont(ofSize: 45)
        self.progressRing.setProgress(value: progress, animationDuration: 1.5)
    }
    
    func setUI(for classObj: Class) {
        self.color = classObj.color
        self.progress = CGFloat(Class.calculateScore(in: classObj))
    }
    
}
