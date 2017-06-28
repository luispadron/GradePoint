//
//  RatingManager.swift
//  GradePoint
//
//  Created by Luis Padron on 6/28/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

class RatingManager {
    static let shared: RatingManager = RatingManager()
    
    func shouldPresentRating() -> Bool {
        return true
    }
}
