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
        
        let rubrics = classObj.rubrics
        let assignmentsByRubric = rubrics.map { classObj.assignments.filter("associatedRubric = %@", $0) }
    
        var weights = 0.0
        var score = 0.0
        
        for (indexOfRubric, rubric) in rubrics.enumerated() {
            let assignments = assignmentsByRubric[indexOfRubric]
            if assignments.count == 0 { continue }
            
            weights += rubric.weight
            
            var total = 0.0
            
            for assignment in assignments {
                total += assignment.score
            }
            
            total /= Double(assignments.count)
            score += rubric.weight * total
        }
        
        self.progress = CGFloat(score / weights)
    }
    
}
