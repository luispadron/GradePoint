//
//  StringExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 1/18/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import Foundation

extension String {
    /// Returns whether or not the string has characters NOT including whitespace
    func isValid() -> Bool {
        let trimmed = self.trimmingCharacters(in: CharacterSet.whitespaces)
        return trimmed.isEmpty ? false : true
    }
}
