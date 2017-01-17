//
//  UIPercentField.swift
//  GradePoint
//
//  Created by Luis Padron on 1/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import UIKit

class UIPercentField: UITextField {
    
    
    private var isBackspace = false
    var allowsAllPercents = false
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
    }
    
    public func shouldChangeText(replacementText string: String) -> Bool {
        // Allow backspace
        if string == "" {
            isBackspace = true
            return true
        }
        
        isBackspace = false
        
        // Allow only one decimal
        if string == "." {
            let text = self.text ?? ""
            return text.components(separatedBy: ".").count < 2
        }
        
        let newChars = CharacterSet(charactersIn: string)
        let isNumber = CharacterSet.decimalDigits.isSuperset(of: newChars)
        
        // If number make sure within range of 0 - 100
        if isNumber {
            let text = self.text ?? ""
            let current = text.replacingOccurrences(of: "%", with: "") + string
            let num = Double(current)
            
            return (num ?? -1) <= 100 && (num ?? -1) >= 0 || allowsAllPercents
        }
        
        return false
    }
    
    @objc private func editingChanged() {
        // Append a percent to the field
        guard var text = self.text, text != "" else {
            return
        }
        
        text = text.replacingOccurrences(of: "%", with: "")
        
        // Add a zero to the start if the user has entered only a decimal
        // Example .1 -> 0.1
        if text == "." { text.insert("0", at: text.startIndex) }
        // If a backspace occured then remove that string and set the field
        if isBackspace { text = text.substring(to: text.index(before: text.endIndex)) }
        // If after deleting the backspaced text, the field is empty, set the field to nil 
        if text == "" {
            self.text = nil
            return
        }
        // Everything is good to go, append the percent symbol
        self.text = text.appending("%")
    }

}
