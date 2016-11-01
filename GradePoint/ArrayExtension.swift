//
//  ArrayExtension.swift
//  GradePoint
//
//  Created by Luis Padron on 11/1/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

extension Array where Element:Equatable {
    
    /// Returns self but only with unique values, i.e removes duplicates
    func unique() -> [Element] {
        var result = [Element]()
        
        for val in self {
            if result.contains(val) == false { result.append(val) }
        }
        
        return result
    }
}
