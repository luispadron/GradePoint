//
//  LPRatingViewDelegate.swift
//  LPIntegratedRating
//
//  Created by Luis Padron on 6/27/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

public protocol LPRatingViewDelegate: class {
    func ratingViewConfiguration(for state: LPRatingViewState) -> LPRatingViewConfiguration?
    func ratingViewDidFinish(with statu:  LPRatingViewCompletionStatus)
    func performOutAnimation(for view: LPRatingView, from currentState: LPRatingViewState, to nextState: LPRatingViewState)
    func performInAnimation(for view: LPRatingView, from currentState: LPRatingViewState, to nextState: LPRatingViewState)
}

public extension LPRatingViewDelegate {
    func performOutAnimation(for view: LPRatingView, from currentState: LPRatingViewState, to nextState: LPRatingViewState) {
        // Basic fade out animation
        UIView.animate(withDuration: view.animationDuration/2) {
            view.titleLabel.alpha = 0.0
            view.rejectionButton.alpha = 0.0
            view.approvalButton.alpha = 0.0
        }
    }
    
    func performInAnimation(for view: LPRatingView, from currentState: LPRatingViewState, to nextState: LPRatingViewState) {
        // Basic fade in animation
        UIView.animate(withDuration: view.animationDuration/2) {
            view.titleLabel.alpha = 1.0
            view.rejectionButton.alpha = 1.0
            view.approvalButton.alpha = 1.0
        }
    }
    
}
