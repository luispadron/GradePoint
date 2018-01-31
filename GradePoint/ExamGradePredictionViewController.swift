//
//  ExamGradePredictionViewController.swift
//  GradePoint
//
//  Created by Luis Padron on 2/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit
import UICircularProgressRing

class ExamGradePredictionViewController: UIViewController {

    // MARK: Properties
    
    // Buttons
    @IBOutlet weak var calculateButton: UIButton!
    // Fields
    @IBOutlet weak var currentGradeField: UISafeTextField!
    @IBOutlet weak var desiredGradeField: UISafeTextField!
    @IBOutlet weak var examWorthField: UISafeTextField!
    // Views
    @IBOutlet weak var needGetLabel: UILabel!
    @IBOutlet weak var progressRing: UICircularProgressRingView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var isInitialCalculation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //////// UI Setup ///////

        // UI Setup for theme
        UIApplication.shared.statusBarStyle = .lightContent
        self.view.backgroundColor = ApplicationTheme.shared.backgroundColor
        self.currentGradeField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.currentGradeField.textColor = ApplicationTheme.shared.mainTextColor()
        self.desiredGradeField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.desiredGradeField.textColor = ApplicationTheme.shared.mainTextColor()
        self.examWorthField.superview?.backgroundColor = ApplicationTheme.shared.lightBackgroundColor
        self.examWorthField.textColor = ApplicationTheme.shared.mainTextColor()
        self.needGetLabel.textColor = ApplicationTheme.shared.mainTextColor()
        self.progressRing.fontColor = ApplicationTheme.shared.mainTextColor()
        self.messageLabel.textColor = ApplicationTheme.shared.mainTextColor()


        let percentConfig = PercentConfiguration(allowsOver100: false, allowsFloatingPoint: true)
        let placeHolderAttrs: [NSAttributedStringKey: Any] = [.foregroundColor: ApplicationTheme.shared.secondaryTextColor()]
        self.currentGradeField.configuration = percentConfig
        self.currentGradeField.fieldType = .percent
        self.currentGradeField.attributedPlaceholder = NSAttributedString(string: "Example: 89%", attributes: placeHolderAttrs)
        self.currentGradeField.keyboardType = .numbersAndPunctuation
        self.currentGradeField.returnKeyType = .next
        
        self.desiredGradeField.configuration = percentConfig
        self.desiredGradeField.fieldType = .percent
        self.desiredGradeField.attributedPlaceholder = NSAttributedString(string: "Example: 90%", attributes: placeHolderAttrs)
        self.desiredGradeField.keyboardType = .numbersAndPunctuation
        self.desiredGradeField.returnKeyType = .next
        
        var examWorthConfig = percentConfig
        examWorthConfig.allowsZeroPercent = false
        self.examWorthField.configuration = examWorthConfig
        self.examWorthField.fieldType = .percent
        self.examWorthField.attributedPlaceholder = NSAttributedString(string: "Example: 20%", attributes: placeHolderAttrs)
        self.examWorthField.keyboardType = .numbersAndPunctuation
        self.examWorthField.returnKeyType = .done
        
        self.calculateButton.setTitleColor(.lightGray, for: .disabled)
        self.calculateButton.isEnabled = false
        
        self.progressRing.font = UIFont.systemFont(ofSize: 50)
        let roundingAmount = UserDefaults.standard.integer(forKey: userDefaultRoundingAmount)
        self.progressRing.decimalPlaces = roundingAmount
    }

    override func viewWillDisappear(_ animated: Bool) {
        // Reset status bar to default
        switch ApplicationTheme.shared.theme {
        case .dark: UIApplication.shared.statusBarStyle = .lightContent
        case .light: fallthrough
        case .eco: UIApplication.shared.statusBarStyle = .default
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Customize font size for segmented control
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            switch traitCollection.horizontalSizeClass {
            case .compact:
                self.progressRing.font = UIFont.systemFont(ofSize: 50)
                self.progressRing.outerRingWidth = 13
                self.progressRing.innerRingWidth = 11
            case .unspecified: fallthrough
            case .regular:
                self.progressRing.font = UIFont.systemFont(ofSize: 70)
                self.progressRing.outerRingWidth = 16
                self.progressRing.innerRingWidth = 14
            }
            
        }
    }

    @IBAction func onExitButtonTap(_ sender: UIButton) {
        // Quickly animate the exit button rotation and dismiss
        UIView.animate(withDuration: 0.25, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.2, options: .curveEaseInOut, animations: {
            sender.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }) { (finished) in
            if finished { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @IBAction func onCalculateButtonTap(_ sender: UIButton) {
        self.view.endEditing(true)
        if isInitialCalculation { animateViews() }
        else { calculateScore() }
    }
    
    @IBAction func textFieldEditingChanged(_ sender: UISafeTextField) {
        // Toggle button based on fields
        self.calculateButton.isEnabled = !self.currentGradeField.safeText.isEmpty && !self.desiredGradeField.safeText.isEmpty && !self.examWorthField.safeText.isEmpty
    }
    
    // MARK: Helper Methods
    
    func animateViews() {
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [], animations: { 
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3, animations: { 
                self.needGetLabel.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: { 
                self.progressRing.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: { 
                self.messageLabel.alpha = 1.0
            })
            
        }) { (finished) in
            if finished { self.calculateScore() }
        }
    }
    
    func calculateScore() {
        if self.isInitialCalculation { self.isInitialCalculation = false }
        guard let currentGrade = Double(currentGradeField.safeText), let desiredGrade = Double(desiredGradeField.safeText),
        let examWorth = Double(examWorthField.safeText) else {
            self.progressRing.setProgress(value: 0.0, animationDuration: 0)
            return
        }
        
        let gradeNeeded = CGFloat((100.0 * desiredGrade - (100.0 - examWorth) * currentGrade)/examWorth)
        
        // Number too big and will look weird in UI, also very unrealistic, notify the user
        if gradeNeeded > 999 {
            self.progressRing.setProgress(value: 0, animationDuration: 0)
            self.messageLabel.text = "Score needed too high, try again."
        } else if gradeNeeded < 0 {
            self.progressRing.setProgress(value: 0, animationDuration: 0)
            self.messageLabel.text = "Score needed less than zero, try again"
        } else {
            self.progressRing.setProgress(value: gradeNeeded, animationDuration: 1.5) { [unowned self] in
                self.messageLabel.text = ScoreMessage.createMessage(forScore: gradeNeeded)
            }
        }
    }
}

// MARK: TextField Delegation
extension ExamGradePredictionViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Switch between the fields
        switch textField {
        case currentGradeField:
            textField.resignFirstResponder()
            desiredGradeField.becomeFirstResponder()
        case desiredGradeField:
            textField.resignFirstResponder()
            examWorthField.becomeFirstResponder()
        case examWorthField:
            textField.resignFirstResponder()
        default:
            self.view.endEditing(true)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let field = textField as? UISafeTextField else { return false }
        return field.shouldChangeTextAfterCheck(text: string)
    }
}

// MARK: Messages Struct
struct ScoreMessage {
    
    private static var easyMessages = ["Thats easy, nice job!", "Wow, you easily got this!",
                                       "Too easy...", "Does 2 + 2 = 4? Thats how hard you need to try.",
                                       "Really easy, nice!", "Piece of cake!" ]
    
    private static var mediumMessage = ["Not too bad, study a bit", "Meh, I've seen worse.",
                                        "Doesn't seem to hard, you got this", "Not too difficult."]
    
    private static var hardMessage = ["Dang! Goodluck", "I believe in you... Sort of.", "It's going to take some work.",
                                      "Hmmm... Maybe you can do it?", "Get to studying now!"]
    
    private static var extremelyHardMessage = ["Ok I don't know about this one, but goodluck!", "Ouch...",
                                               "Is this even possible?", "Beg for extra credit", "I'm so sorry...",
                                               "Wow thats tough.", "Good luck..."]
    
    
    static func createMessage(forScore score: CGFloat) -> String {
        switch Int(score) {
        case 0...60: // Easy messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.easyMessages.count)
            return ScoreMessage.easyMessages[index]
        case 61...79: // Medium messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.mediumMessage.count)
            return ScoreMessage.mediumMessage[index]
        case 80...100: // Hard messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.hardMessage.count)
            return ScoreMessage.hardMessage[index]
        default: // Extremely hard messages
            let index: Int = .random(withLowerBound: 0, andUpperBound: ScoreMessage.extremelyHardMessage.count)
            return ScoreMessage.extremelyHardMessage[index]
        }
    }
}
