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

class UIRubricView: UIView, UITextFieldDelegate {
    
    // MARK: Properties
    
    var shouldDrawCircle: Bool = false
    
    var circleSpacing: CGFloat = 30
    var radius: CGFloat = 17
    
    var addButtonOffSet: CGFloat = 1
    var addColor: UIColor = UIColor.green
    var deleteColor: UIColor = UIColor.red
    var plusColor: UIColor = UIColor.highlight
    
    var nameFieldPrompt: String = "Name"
    var weightFieldPrompt: String = "Weight"
    
    var fontSize: CGFloat = 18
    
    var animationDuration: TimeInterval = 0.4
    
    var buttonRect: CGRect?
    var isDeleteButton: Bool = false {
        didSet {
            updateIsRubricValid()
        }
    }
    
    var isAnimating: Bool = false
    
    var circleLayer: CAShapeLayer?
    
    var promptLabel: UILabel!
    var nameField: UIFloatingPromptTextField!
    var weightField: UIFloatingPromptTextField!
    var isBackspace = false
    
    private lazy var plusLayer = CAShapeLayer()
    lazy var buttonGesture = UITapGestureRecognizer()
    
    weak var delegate: UIRubricViewDelegate?
    
    var parentCell: RubricTableViewCell!
    
    var isRubricValid = false {
        didSet {
            delegate?.isRubricValidUpdated(forView: self)
        }
    }
    
    // MARK: Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.darkBg
        drawButton()
        drawPromptLabel()
        drawTextField()
        initGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.darkBg
        drawButton()
        drawPromptLabel()
        drawTextField()
        initGestureRecognizer()
    }
    
    override func layoutSubviews() {
        // Remove these views and redraw them
        drawButton()
        let actualWidth = bounds.width - (plusLayer.bounds.maxX + 50) - 50 - plusLayer.bounds.width
        let width = bounds.width - (plusLayer.bounds.maxX + 50)
        promptLabel.frame = CGRect(x: plusLayer.bounds.maxX + 50, y: bounds.minY, width: width, height: bounds.height)
        nameField.frame = CGRect(x: plusLayer.bounds.maxX + 50, y: bounds.minY, width: actualWidth/2, height: bounds.height)
        weightField.frame = CGRect(x: nameField.bounds.maxX + 100, y: bounds.minY, width: actualWidth/2, height: bounds.height)
        updateIsRubricValid()
        super.layoutSubviews()
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
        if #available(iOS 10.0, *) {
            promptLabel.textColor = UIColor(displayP3Red:0.780, green: 0.780, blue: 0.804, alpha:1.00)
        } else {
            // Fallback on earlier versions
            promptLabel.textColor = UIColor(red:0.780, green: 0.780, blue: 0.804, alpha:1.00)
        }
        promptLabel.font = UIFont.systemFont(ofSize: fontSize)
        promptLabel.textColor = UIColor.mutedText
        self.addSubview(promptLabel)
    }
    
    private func drawTextField() {
        let actualWidth = bounds.width - (plusLayer.bounds.maxX + 50) - 50 - plusLayer.bounds.width
        
        nameField = UIFloatingPromptTextField(frame:  CGRect(x: plusLayer.bounds.maxX + 50, y: bounds.minY,
                                                             width: actualWidth/2, height: bounds.height))
        nameField.placeholder = nameFieldPrompt
        nameField.textColor = UIColor.lightText
        nameField.borderStyle = .none
        nameField.font = UIFont.systemFont(ofSize: fontSize)
        nameField.titleText = nameFieldPrompt
        nameField.attributedPlaceholder = NSAttributedString(string: nameFieldPrompt, attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        nameField.returnKeyType = .next
        nameField.isHidden = true
        nameField.delegate = self
        nameField.addTarget(self, action: #selector(self.updateIsRubricValid), for: .editingChanged)
        self.addSubview(nameField)
        
        weightField = UIFloatingPromptTextField(frame: CGRect(x: nameField.bounds.maxX + 100, y: bounds.minY,
                                                              width: actualWidth/2, height: bounds.height))
        
        weightField.placeholder = weightFieldPrompt
        weightField.textColor = UIColor.lightText
        weightField.borderStyle = .none
        weightField.font = UIFont.systemFont(ofSize: fontSize)
        weightField.titleText = weightFieldPrompt
        weightField.attributedPlaceholder = NSAttributedString(string: weightFieldPrompt, attributes: [NSForegroundColorAttributeName: UIColor.mutedText])
        weightField.returnKeyType = .done
        weightField.isHidden = true
        weightField.delegate = self
        weightField.addTarget(self, action: #selector(self.weightFieldTextChanged), for: .editingChanged)
        weightField.keyboardType = .decimalPad
        
        // Add an input accessory view which will display done
        let weightFieldToolBar = UIToolbar()
        weightFieldToolBar.barStyle = .default
        weightFieldToolBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.keyboardDone))
        ]
        weightFieldToolBar.sizeToFit()
        weightFieldToolBar.barTintColor = UIColor.darkBg
        weightFieldToolBar.isTranslucent = false
        weightField.inputAccessoryView = weightFieldToolBar
        
        self.addSubview(weightField)
        
    }
    
    func keyboardDone() {
        endEditing(true)
    }
    
    // MARK: Actions
    
    @objc private func tappedOnButton() {
        guard let buttonRect = buttonRect else {
            print("Button rect not found when tapped on button")
            return
        }
        
        let state: UIRubricViewState = self.isDeleteButton ? .open : .collapsed
        let point = buttonGesture.location(in: self)
        
        if (buttonRect.contains(point) || state == .collapsed) && !isAnimating {
            self.delegate?.plusButtonTouched(inCell: self.parentCell, withState: state)
        }
    }
    
    func animateViews() {
        isAnimating = true
        // Create rotate animation
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(45).toRads
        
        rotateAnimation.duration = animationDuration
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.fillMode = kCAFillModeForwards
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        // Create the background color change animation
        let backgroundAnimation = CABasicAnimation(keyPath: "fillColor")
        backgroundAnimation.fromValue = addColor.cgColor
        backgroundAnimation.toValue = deleteColor.cgColor
        
        if isDeleteButton {
            rotateAnimation.fromValue = CGFloat(45).toRads
            rotateAnimation.toValue = 0.0

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
        if promptLabel.isHidden { // The user has clicked the delete button and the two textfields will be hidden
            // Prepare for animation
            nameField.layer.opacity = 1.0
            weightField.layer.opacity = 1.0
            self.promptLabel.isHidden = false
            promptLabel.layer.opacity = 0.0
            
            UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: [.calculationModeLinear], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.nameField.layer.opacity = 0.0
                    self.weightField.layer.opacity = 0.0
                })
                
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                    self.promptLabel.layer.opacity = 1.0
                })
                
                
                }, completion: { _ in
                    self.isAnimating = false
                    self.toggleFields()
                    self.nameField.isHidden = true
                    self.weightField.isHidden = true
                    self.toggleFields()
                    self.isDeleteButton = self.isDeleteButton.toggle
            })
        } else { // The user has clicked the add button and the two textfields will now be shown
            promptLabel.layer.opacity = 1.0
            nameField.isHidden = false
            weightField.isHidden = false
            nameField.layer.opacity = 0.0
            weightField.layer.opacity = 0.0
            
            UIView.animateKeyframes(withDuration: animationDuration, delay: 0.0, options: [], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2, animations: {
                    self.promptLabel.layer.opacity = 0.0
                })
                
                UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                    self.nameField.layer.opacity = 1.0
                    self.weightField.layer.opacity = 1.0
                })
                
                
                }, completion: { _ in
                    self.isAnimating = false
                    self.toggleFields()
                    self.promptLabel.isHidden = true
                    self.isDeleteButton = self.isDeleteButton.toggle
            })
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            isBackspace = true
            return true
        }
        
        isBackspace = false
        
        // Dont allow multiple periods, anything below 0 or above 100
        if textField === weightField {
            let newChars = CharacterSet(charactersIn: string)
            let isNumber = CharacterSet.decimalDigits.isSuperset(of: newChars)
            if isNumber {
                let current = textField.text!.replacingOccurrences(of: "%", with: "") + string
                let num = Double(current)
                if let n = num,  n > 100.0 || n < 0.0 { return false }
            } else { // Allow only one decimal
                if string == "." {
                    let current = textField.text!.replacingOccurrences(of: "%", with: "") + string
                    let num = Double(current)
                    let count = textField.text!.components(separatedBy: ".").count
                    if count > 1 { return false }
                    if let n = num,  n >= 100 || n < 0 { return false }
                    
                    return true
                }
                // Not a number or decimal point, return false
                return false
            }
        }
        
        return true
    }
    
    // Append a "%" sign to the end of the string in the textfield
    func weightFieldTextChanged(textField: UITextField) {
        
        guard var text = textField.text, text != "" else {
            updateIsRubricValid()
            return
        }
        
        // Replace all % and treat string as if the % doesnt matter
        text = text.replacingOccurrences(of: "%", with: "")
        
        if text == "." {
            text.insert("0", at: text.startIndex)
        }
        // If it's a back space then remove that string and set the field
        if isBackspace {
            text = text.substring(to: text.index(before: text.endIndex))
        }
        
        // If after deleting the text = "" then just set textfield text to empty, and return 
        // We dont want to append just % because that would look weird, so return and dont append
        if text == "" {
            textField.text = nil
            updateIsRubricValid()
            return
        }
        
        // All statements passed, lets set the textfields text
        textField.text = text.appending("%")
        
        updateIsRubricValid()
    }
    
    func updateIsRubricValid() {
        // The user hasnt opened the rubric view, thus, no checking required
        if !isDeleteButton {
            isRubricValid = true
            return
        }
        
        // Check the name field for whitespace, and the weightfield if its empty
        guard let nText = nameField.text, let wText = weightField.text, !nText.isEmpty, !wText.isEmpty else {
            isRubricValid = false
            return
        }
        
        let trimmed = nText.trimmingCharacters(in: CharacterSet.whitespaces)
        isRubricValid = trimmed.isEmpty ? false : true
    }
    
    func toEditState() {
        // Rotate add button
        plusLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(45).toRads))
        
        // Toggle the textfield
        self.toggleFields()
        self.promptLabel.isHidden = true
        self.nameField.isHidden = false
        self.weightField.isHidden = false
        
        DispatchQueue.main.async {
            self.nameField.editingChanged()
            self.weightField.editingChanged()
        }
        self.isDeleteButton = self.isDeleteButton.toggle
        self.isRubricValid = true
        
        self.delegate?.plusButtonTouched(inCell: parentCell, withState: nil)
    }

}
