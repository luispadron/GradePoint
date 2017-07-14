//
//  Array+Extensions.swift
//  GradePoint
//
//  Created by Luis Padron on 7/12/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

extension Array where Element : Collection, Element.Iterator.Element : Equatable, Element.Index == Int {
    /// Returns the indices of an object inside a two dimensional array
    func indices(of x: Element.Iterator.Element) -> (Int, Int)? {
        for (i, array) in self.enumerated() {
            if let j = array.index(of: x) {
                return (i, j)
            }
        }
        
        return nil
    }
    
    /// Returns whether or not an array is actually empty, this is used for 2D arrays
    /// Since Swift thinks empty collections inside an array count as valid items even though they're all empty
    var isTrueEmpty: Bool {
        get {
            var count: Int = 0
            for (_, array) in self.enumerated() {
                for (_, _) in array.enumerated() {
                    count += 1
                }
            }
            return count == 0
        }
    }
}
