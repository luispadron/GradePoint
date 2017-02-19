//
//  UICircularProgressRing+Calculate.swift
//  GradePoint
//
//  Created by Luis Padron on 2/18/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UICircularProgressRing

extension UICircularProgressRingView {

    /// Sets the progress based on the class object that was passed in
    func setProgress(for classObj: Class, animationDuration duration: TimeInterval, completion: UICircularProgressRingView.ProgressCompletion? = nil) {
        let progress = UICircularProgressRingView.getProgress(for: classObj)
        self.setProgress(value: progress, animationDuration: duration, completion: completion)
    }
    
    /// Returns the progress for a specific class. I.e loops through the assignments and calculates the score for the class
    static func getProgress(for classObj: Class) -> CGFloat {
        let assignmentsSectionedByRubric = classObj.rubrics.map { classObj.assignments.filter("associatedRubric = %@", $0) }
        
        var weights = 0.0
        var totalScore = 0.0
        
        for assignments in assignmentsSectionedByRubric {
            if assignments.count == 0 { continue }
            weights += assignments[0].associatedRubric!.weight
            
            var sumTotal = 0.0
            for assignment in assignments { sumTotal += assignment.score }
            
            sumTotal /= Double(assignments.count)
            totalScore += assignments[0].associatedRubric!.weight * sumTotal
        }
        
        return CGFloat(totalScore / weights)
    }
}
