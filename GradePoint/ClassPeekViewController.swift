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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressRing.innerRingColor = color ?? self.progressRing.innerRingColor
        self.progressRing.outerRingColor = color?.darker(by: 15) ?? self.progressRing.outerRingColor
        self.progressRing.font = UIFont.systemFont(ofSize: 45)
        self.progressRing.setProgress(value: progress, animationDuration: 1.5)
    }

    func setProgress(for classObj: Class) {
        self.color = classObj.color
        self.progress = CGFloat(Class.calculateScore(in: classObj))
    }
    
}
