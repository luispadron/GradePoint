//
//  BasicInfoDateTapDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 10/21/16.
//  Copyright © 2016 Luis Padron. All rights reserved.
//

import Foundation
import UIKit

protocol BasicInfoDateDelegate {
    func dateInputWasTapped(forCell cell: BasicInfoDateTableViewCell)
    
    func pickerRowSelected(semester: String, year: Int) 
}
