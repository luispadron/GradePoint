//
//  UIAnimatedTextField.swift
//  UIAnimatedTextField
//
//  Created by Luis Padron on 9/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import UIKit

private extension CGFloat {
    var toRads: CGFloat { return self * CGFloat(M_PI) / 180 }
}

private extension Bool {
    var toggle: Bool { return self ? false : true }
}

@IBDesignable class UIRubricView: UIView, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBInspectable var shouldDrawCircle: Bool = false
    
    @IBInspectable var circleSpacing: CGFloat = 20
    @IBInspectable var radius: CGFloat = 12
    
    @IBInspectable var addButtonOffSet: CGFloat = 1
    @IBInspectable var addColor: UIColor = UIColor.green
    @IBInspectable var deleteColor: UIColor = UIColor.red
    @IBInspectable var plusColor: UIColor = UIColor.blue
    
    @IBInspectable var nameFieldPrompt: String = "Name"
    @IBInspectable var weightFieldPrompt: String = "Weight"
    
    @IBInspectable var fontSize: CGFloat = 17
    
    @IBInspectable var animationDuration: TimeInterval = 0.3
    
    private var buttonRect: CGRect?
    private var isDeleteButton: Bool = false
    private var isAnimating: Bool = false
    
    private var circleLayer: CAShapeLayer?
    
    var promptLabel: UILabel!
    var nameField: UIFloatingPromptTextField!
    var weightField: UIFloatingPromptTextField!
    
    private lazy var plusLayer = CAShapeLayer()
    private lazy var buttonGesture = UITapGestureRecognizer()
    
    var delegate: UIRubricViewDelegate?
    
    // MARK: Overrides
    
    override func draw(_ rect: CGRect) {
        // Draw the button
        drawButton()
        drawPromptLabel()
        drawTextField()
        initGestureRecognizer()
    }
    
    // MARK: Helper methods
    
    private func initGestureRecognizer() {
        buttonGesture.addTarget(self, action: #selector(self.tappedOnButton))
        buttonGesture.numberOfTapsRequired = 1
        buttonGesture.numberOfTouchesRequired = 1
        self.addGestureRecognizer(buttonGesture)
        
    }
    
    private func drawButton() {
        let circle = UIBezierPath(arcCenter: CGPoint(x: bounds.minX + circleSpacing, y: bounds.midY), radius: radius,
                                startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2),
                                clockwise: true)
        
        if shouldDrawCircle {
            circleLayer = CAShapeLayer()
            circleLayer!.path = circle.cgPath
            circleLayer!.strokeColor = nil
            circleLayer!.fillColor = addColor.cgColor
            circleLayer!.lineWidth = 1.0
            circleLayer!.frame = circle.bounds
            circleLayer!.bounds = circle.bounds
            self.layer.addSublayer(circleLayer!)
        }
        
        // Draw the plus button
        let circleBounds = circle.bounds
        let plusHeight: CGFloat = 3.0
        let plusWidth: CGFloat = min(circleBounds.width, circleBounds.height) * 0.6
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = plusHeight
        plusPath.lineCapStyle = .square
        
        plusPath.move(to: CGPoint(x: circleBounds.midX - plusWidth/2 + 0.5 + addButtonOffSet, y: bounds.midY + 0.5))
        plusPath.addLine(to: CGPoint(x: circleBounds.midX + plusWidth/2 + 0.5 - addButtonOffSet, y: bounds.midY + 0.5))
        
        plusPath.move(to: CGPoint(x: circleBounds.midX + 0.5, y: circleBounds.midY - plusWidth/2 + 0.5 + addButtonOffSet))
        plusPath.addLine(to: CGPoint(x: circleBounds.midX + 0.5, y: circleBounds.midY + plusWidth/2 + 0.5 - addButtonOffSet))
        
        plusLayer.path = plusPath.cgPath
        plusLayer.strokeColor = plusColor.cgColor
        plusLayer.fillColor = nil
        plusLayer.lineWidth = plusHeight
        plusLayer.lineJoin = kCALineCapSquare
        plusLayer.frame = plusPath.bounds
        plusLayer.bounds = plusPath.bounds
        
        self.layer.addSublayer(plusLayer)
        
        buttonRect = circleBounds
    }
    
    private func toggleFields() {
        if nameField.isHidden && nameField.isFirstResponder { nameField.resignFirstResponder() }
        else { nameField.becomeFirstResponder() }
        if weightField.isFirstResponder { weightField.resignFirstResponder() }
    }
    
    private func drawPromptLabel() {
        let width = bounds.width - (plusLayer.bounds.maxX + 50)
        promptLabel = UILabel(frame: CGRect(x: plusLayer.bounds.maxX + 50, y: bounds.minY, width: width, height: bounds.height))
        promptLabel.text = "Add a grade section"
        promptLabel.textColor = UIColor(displayP3Red:0.780, green: 0.780, blue: 0.804, alpha:1.00)
        promptLabel.font = UIFont.systemFont(ofSize: fontSize)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.animateViews))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        promptLabel.addGestureRecognizer(tap)
        promptLabel.isUserInteractionEnabled = true
        self.addSubview(promptLabel)
    }
    
    private func drawTextField() {
        let actualWidth = bounds.width - (plusLayer.bounds.maxX + 50) - 50 - plusLayer.bounds.width
        
        nameField = UIFloatingPromptTextField(frame:  CGRect(x: plusLayer.bounds.maxX + 50, y: bounds.minY,
                                                            width: actualWidth/2, height: bounds.height))
        nameField.placeholder = nameFieldPrompt
        nameField.textColor = UIColor.blue
        nameField.borderStyle = .none
        nameField.font = UIFont.systemFont(ofSize: fontSize)
        nameField.titleText = nameFieldPrompt
        nameField.returnKeyType = .next
        nameField.isHidden = true
        nameField.delegate = self
        self.addSubview(nameField)
        
        weightField = UIFloatingPromptTextField(frame: CGRect(x: nameField.bounds.maxX + 100, y: bounds.minY,
                                                              width: actualWidth/2, height: bounds.height))
        
        weightField.placeholder = weightFieldPrompt
        weightField.textColor = UIColor.blue
        weightField.borderStyle = .none
        weightField.font = UIFont.systemFont(ofSize: fontSize)
        weightField.titleText = weightFieldPrompt
        weightField.returnKeyType = .done
        weightField.isHidden = true
        weightField.delegate = self
        self.addSubview(weightField)
        
    }
    

    @objc private func animateViews() {
        if isAnimating { return }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.delegate?.buttonTapped()
            self.isAnimating = false
            self.isDeleteButton = self.isDeleteButton.toggle
            self.toggleFields()
        })
        isAnimating = true
        // Create rotate animation
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(45).toRads
        
        if isDeleteButton {
            rotateAnimation.fromValue = CGFloat(45).toRads
            rotateAnimation.toValue = 0.0
        }
        rotateAnimation.duration = animationDuration
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Create the background color change animation
        let backgroundAnimation = CABasicAnimation(keyPath: "fillColor")
        backgroundAnimation.fromValue = addColor.cgColor
        backgroundAnimation.toValue = deleteColor.cgColor
        
        if isDeleteButton {
            backgroundAnimation.fromValue = deleteColor.cgColor
            backgroundAnimation.toValue = addColor.cgColor
        }
        backgroundAnimation.duration = animationDuration
        backgroundAnimation.isRemovedOnCompletion = false
        backgroundAnimation.fillMode = kCAFillModeForwards
        backgroundAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        plusLayer.add(rotateAnimation, forKey: "transform.rotation")
        circleLayer?.add(backgroundAnimation, forKey: "backgroundAnimation")
        
        // Animate opacity of views
        if promptLabel.isHidden {
            nameField.layer.opacity = 1.0
            weightField.layer.opacity = 1.0
            
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.nameField.layer.opacity = 0.0
                self.weightField.layer.opacity = 0.0
                
                }, completion: { [unowned self] (complete) in
                    if complete {
                        self.nameField.isHidden = true
                        self.weightField.isHidden = true
                        self.promptLabel.isHidden = false
                        self.promptLabel.layer.opacity = 0.0
                        self.toggleFields()
                        UIView.animate(withDuration: self.animationDuration, animations: {
                            self.promptLabel.layer.opacity = 1.0
                        })
                    }
            })
        } else {
            promptLabel.layer.opacity = 1.0
            UIView.animate(withDuration: animationDuration, animations: { [unowned self] in
                self.promptLabel.layer.opacity = 0.0
                
                }, completion: { [unowned self] (complete) in
                    if complete {
                        self.promptLabel.isHidden = true
                        self.nameField.isHidden = false
                        self.weightField.isHidden = false
                        self.nameField.layer.opacity = 0.0
                        self.weightField.layer.opacity = 0.0
                        UIView.animate(withDuration: self.animationDuration, animations: {
                            self.nameField.layer.opacity = 1.0
                            self.weightField.layer.opacity = 1.0
                        })
                    }
                })
        }
        CATransaction.commit()
    }
    
    @objc private func tappedOnButton() {
        guard let rect = buttonRect else {
            return
        }
        
        let point = buttonGesture.location(in: self)

        if rect.contains(point) {
            animateViews()
        }
    }
    
    
    // MARK: TextField Delegates

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField !== nameField {
            weightField.resignFirstResponder()
            return true
        }
        
        nameField.resignFirstResponder()
        weightField.becomeFirstResponder()
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
}
