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
    
    // MARK: - Initializers
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public convenience init(frame: CGRect, fieldType: FieldType, configuration: FieldConfiguration) {
        self.init(frame: frame)
        self.fieldType = fieldType
        self.configuration = configuration
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
            break
        case .percent:
            // Append a percent to the end of the text field
            guard var textToChange = self.text?.replacingOccurrences(of: "%", with: "") else { return }
            // If only entered a dot, prepend a 0, i.e .1 -> 0.1
            if textToChange == "." { textToChange.insert("0", at: textToChange.startIndex) }
            // Remove the last char
            if isBackspace { textToChange = textToChange.substring(to: textToChange.index(before: textToChange.endIndex)) }
            // If after removing a char text is empty, then set self.text to nil since no text
            if textToChange == "" { self.text = nil; return }
            // All good to append a percent
            self.text = textToChange.appending("%")
        case .text:
            break
        }
    }
    
    /// MARK: - Helper Methods
    
    ///////////// NUMBER ///////////////
    
    private func checkValidNumber(for string: String) -> Bool {
        return false
    }
    
    private func checkValidNumber(for string: String, with configuration: NumberConfiguration) -> Bool {
        return false
    }
    
    ///////////// PERCENT ///////////////
    
    /// Checks to see if valid percent, this would mean that text can be converted into a number
    private func checkValidPercent(for string: String) -> Bool {
        // Allow only one decimal dot
        if string == "." && !(self.text?.contains(".") ?? false) { return (self.text?.components(separatedBy: ".") ?? [""]).count < 2 }
        // Make sure string is a number
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else { return false }
        
        return false
    }
    
    private func checkValidPercent(for string: String, with configuration: PercentConfiguration) -> Bool {
        guard checkValidPercent(for: string) else { return false }
        
        let currentText = self.text?.replacingOccurrences(of: "", with: "%") ?? ""
        
        // If allows floating point, must be convertable to double or float
        var convertable = true
        if configuration.allowsFloatingPoint { convertable = Double(currentText + string) != nil || Float(currentText + string) != nil }
        // If allows over 100 just make sure it isnt below 0, if doesnt allow over 100 then check that its within range
        var inRange = true
        if configuration.allowsOver100 && configuration.allowsFloatingPoint { inRange = (Double(currentText + string) ?? -1.0 )  > 0.0 }
        else if configuration.allowsOver100 { inRange = (Int(currentText + string) ?? -1 )  > 0 }
        else { inRange = (Int(currentText + string) ?? -1 ) >= 0 && (Int(currentText + string) ?? -1 ) <= 100 }
        
        return convertable && inRange
    }
    
    ///////////// TEXT ///////////////
    
    private func checkValidText(for string: String) -> Bool {
        return false
    }
    
    private func checkValidText(for string: String, with configuration: TextConfiguration) -> Bool {
        return false
    }
    
}






