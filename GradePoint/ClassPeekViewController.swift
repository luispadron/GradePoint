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
    var indexPathForPeek: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.progressRing.setProgress(value: progress, animationDuration: 1.5)
        
    }

    func calculateProgress(for classObj: Class) {
        guard classObj.assignments.count > 0 else { return }
        self.progress = UICircularProgressRingView.getProgress(for: classObj)
    }
    
}
