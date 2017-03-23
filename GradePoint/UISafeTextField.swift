//
//  UISafeTextField.swift
//  GradePoint
//
//  Created by Luis Padron on 2/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

/// A safe textfield, can be used for numbers, percents, or text
open class UISafeTextField: UITextField {
    /// An enum for the textfield type
    public enum FieldType {
        case number, percent, text
    }
    
    /// The type of the textfield
    open var fieldType: FieldType = .text
    /// The configuration for the text field
    open var configuration: FieldConfiguration = TextConfiguration(maxCharacters: Int.max)
    /// Boolean for determining if the user clicked backspace
    private var isBackspace: Bool = false
    /// Returns a safe text, this will remove any special characters added to the text
    /// Such as the '%' character when using .percent type
    open var safeText: String { get { return (self.text ?? "").replacingOccurrences(of: "%", with: "") } }
    
    // MARK: - Initializers
    
    public required init(frame: CGRect, fieldType: FieldType, configuration: FieldConfiguration) {
        self.fieldType = fieldType
        self.configuration = configuration
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        // Add target
        self.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        // Set keyboard type
        switch fieldType {
        case .percent:
            fallthrough
        case .number:
            self.keyboardType = .decimalPad
        case .text:
            break
        }
    }
    
    // MARK: - Check Methods
    
    /// The function which checks the entered type and checks to see whether it is valid according to the
    /// `fieldType` that is set. Call this in the `shouldChange(:)` of the UITextFieldDelegate method
    public func shouldChangeTextAfterCheck(text: String) -> Bool {
        if text == "" { isBackspace = true; return true }
        else { isBackspace = false }
        
        switch fieldType {
        case .number:
            guard let config = configuration as? NumberConfiguration else {
                NSLog("WARNING: Field type is \(fieldType) but configuration is \(configuration.self)")
                return checkValidNumber(for: text)
            }
            return checkValidNumber(for: text, with: config)
        case .percent:
            guard let config = configuration as? PercentConfiguration else {
                NSLog("WARNING: Field type is \(fieldType) but configuration is \(configuration.self)")
                return checkValidPercent(for: text)
            }
            return checkValidPercent(for: text, with: config)
        case .text:
            guard let config = configuration as? TextConfiguration else {
                NSLog("WARNING: Field type is \(fieldType) but configuration is \(configuration.self)")
                return checkValidText(for: text)
            }
            return checkValidText(for: text, with: config)
        }
    }
    
    /// Does some fancy stuff after changing the text in the field, such as appending a '%' symbol if the field is of type .percent
    @objc private func textDidChange(textField: UITextField) {
        switch fieldType {
        case .number:
            guard var currentText = self.text else { return }
            // If only entered a dot, prepend a 0, i.e .1 -> 0.1
            if currentText == "." { currentText.insert("0", at: currentText.startIndex) }
            self.text = currentText
        case .percent:
            // Append a percent to the end of the text field
            guard var currentText = self.text?.replacingOccurrences(of: "%", with: "") else { return }
            // If only entered a dot, prepend a 0, i.e .1 -> 0.1
            if currentText == "." { currentText.insert("0", at: currentText.startIndex) }
            // Remove the last char
            if isBackspace { currentText = currentText.substring(to: currentText.index(before: currentText.endIndex)) }
            // If after removing a char text is empty, then set self.text to nil since no text
            if currentText == "" { self.text = nil; return }
            // All good to append a percent
            self.text = currentText.appending("%")
        case .text:
            break
        }
    }
    
    /// MARK: - Helper Methods
    
    ///////////// NUMBER ///////////////
    
    /// Checks to see if valid number, this would mean that text can be converted into a number
    private func checkValidNumber(for string: String) -> Bool {
        // Allow backspace
        if string == "" { return true }
        else if string == "." && !(self.text?.contains(".") ?? false) { return (self.text?.components(separatedBy: ".") ?? [""]).count < 2 } // Allow only one decimal dot
        // Only allow digits
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else { return false }
        
        return true
    }
    
    /// Checks to see if its a valid number AND if meets configurations defined in the NumberConfiguration
    private func checkValidNumber(for string: String, with configuration: NumberConfiguration) -> Bool {
        guard checkValidNumber(for: string) else { return false }
    
        if string == "." && !configuration.allowsFloating { return false }
        else if string == "" || (string == "." && configuration.allowsFloating) { return true } // These have already been checked, just return true
        else if string == "-" && !(self.text?.contains("-") ?? false) && configuration.allowsSignedNumbers { return (self.text?.components(separatedBy: "-") ?? [""]).count < 2 } // Allow only one - for negative
        
        
        let currentText = self.text ?? ""
        
        // Make sure number can be converted
        let convertable = Double(currentText + string) != nil || Int(currentText + string) != nil || Float(currentText + string) != nil
        
        // If doesnt allow signed numbers then check to see if number is signed
        var isValidNumber = true
        if !configuration.allowsSignedNumbers { isValidNumber = Double(currentText + string)! > 0.0 }
        
        // Make sure number is in range
        var inRange = true
        if let range = configuration.range { inRange = range.contains(Double(currentText + string)!) }
        
        // Not in range, and has - in textfield, this would mean that configuration allowed for signed nubmers but didnt set correct range
        // I.e a range of 0...3
        if !inRange && !currentText.isEmpty && currentText.characters[currentText.startIndex] == "-" && currentText.characters.count == 1 {
            self.text = nil // Removes that - and returns nil
            return false
        }
        
        return convertable && isValidNumber && inRange
    }
    
    ///////////// PERCENT ///////////////
    
    /// Checks to see if valid percent, this would mean that text can be converted into a number
    private func checkValidPercent(for string: String) -> Bool {
        // Allow only one decimal dot
        if string == "." && !(self.text?.contains(".") ?? false) { return (self.text?.components(separatedBy: ".") ?? [""]).count < 2 }
        // Make sure string is a number
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else { return false }
        
        return true
    }
    
    /// Checks to see if its a valid percent AND if meets configurations defined in the PercentConfiguration
    private func checkValidPercent(for string: String, with configuration: PercentConfiguration) -> Bool {
        guard checkValidPercent(for: string) else { return false }
        
        if string == "." && configuration.allowsFloatingPoint { return true }
        else if string == "." && !configuration.allowsFloatingPoint { return false }
        
        let currentText = self.text?.replacingOccurrences(of: "%", with: "") ?? ""
        
        // If allows floating point, must be convertable to double or float
        var convertable = true
        if configuration.allowsFloatingPoint { convertable = Double(currentText + string) != nil || Float(currentText + string) != nil }
        
        // If allows over 100 just make sure it isnt below 0, if doesnt allow over 100 then check that its within range
        var inRange = true
        
        if configuration.allowsFloatingPoint {
            if configuration.allowsOver100 { inRange = (Double(currentText + string) ?? -1.0 ) >=  0.0 }
            else { inRange = (Double(currentText + string) ?? -1.0 ) <=  100.0 }
            
            if !configuration.allowsZeroPercent { inRange = (Double(currentText + string) ?? -1.0 ) >  0.0 }
        } else if !configuration.allowsFloatingPoint {
            if configuration.allowsOver100 { inRange = (Int(currentText + string) ?? -1) >= 0 }
            else { inRange = (Int(currentText + string) ?? -1) <= 100 }
            
            if !configuration.allowsZeroPercent { inRange = (Int(currentText + string) ?? -1) > 0 }
        }
        
        return convertable && inRange
    }
    
    ///////////// TEXT ///////////////
    
    private func checkValidText(for string: String) -> Bool {
        return true
    }
    
    private func checkValidText(for string: String, with configuration: TextConfiguration) -> Bool {
        guard checkValidText(for: string) else { return false }
        
        let currentText = self.text ?? ""
        // Check to see if in range
        let inRange = (currentText + string).characters.count <= configuration.maxCharacters
        
        return inRange
    }
    
}






