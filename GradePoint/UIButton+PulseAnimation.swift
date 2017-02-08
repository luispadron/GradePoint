//
//  UIButton+PulseAnimation.swift
//  GradePoint
//
//  Created by Luis Padron on 2/7/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

extension UIButton {
    /// Animates a UIButton with a pulse animation
    public func animateWithPulse(withDuration duration: TimeInterval, completion: (() -> Void)? = nil) {
        // Mask this layer, so that the pulse doesn't extend outside of the animation
        self.layer.masksToBounds = true
        
        // Create the scale animation
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        scaleAnimation.duration = duration
        scaleAnimation.values = [0.3, 0.5, 0.6, 0.8, 1.0]
        scaleAnimation.keyTimes = [0.0, 0.3, 0.4, 0.5, 0.7]
        
        // Create the opacity animation
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = duration
        opacityAnimation.values = [0.0, 0.2, 0.6, 0.8, 0.3, 0.0]
        opacityAnimation.keyTimes = [0.0, 0.1, 0.3, 0.5, 0.7, 1.0]
        // The group for the animations
        let group = CAAnimationGroup()
        group.duration = duration
        group.repeatCount = 1
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        group.animations = [scaleAnimation, opacityAnimation]
        // The animation layer which will be added ontop of the buttons current layer
        let animationLayer = CALayer()
        let radius = max(self.frame.width, self.frame.height)
        animationLayer.frame = CGRect(x: 0, y: 0, width: radius, height: radius)
        animationLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        animationLayer.cornerRadius = radius/2
        animationLayer.opacity = 0
        animationLayer.backgroundColor = self.backgroundColor?.lighter(by: 20)?.cgColor
        // Add the animation
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // Call the completion block
            completion?()
        }
        animationLayer.add(group, forKey: "pulse")
        // Finally add the layer to this buttons main layer
        self.layer.insertSublayer(animationLayer, at: 0)
        CATransaction.commit()
    }
}
