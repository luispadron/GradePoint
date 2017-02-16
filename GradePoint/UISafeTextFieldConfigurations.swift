//
//  UISafeTextFieldConfigurations.swift
//  GradePoint
//
//  Created by Luis Padron on 2/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

/// Configuration Options for the textfield
public protocol FieldConfiguration {}

/// Configuration for a number textfield
public struct NumberConfiguration: FieldConfiguration {
    public let range: ClosedRange<Int>
    public let allowSignedNumbers: Bool
    
    init(range: ClosedRange<Int>, allowSignedNumbers: Bool = true) {
        self.range = range
        self.allowSignedNumbers = allowSignedNumbers
    }
}

/// Configuration for a percent textfield
public struct PercentConfiguration: FieldConfiguration {
    public let allowsOver100: Bool
    public let allowsFloatingPoint: Bool
    
    init(allowsOver100: Bool, allowsFloatingPoint: Bool) {
        self.allowsOver100 = allowsOver100
        self.allowsFloatingPoint = allowsFloatingPoint
    }
}

/// Configuration for text field
public struct TextConfiguration: FieldConfiguration {
    public let maxCharacters: Int
    
    init(maxCharacters: Int) {
        self.maxCharacters = maxCharacters
    }
}
