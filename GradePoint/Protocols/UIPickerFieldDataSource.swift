//
//  UIPickerFieldDataSource.swift
//  GradePoint
//
//  Created by Luis Padron on 12/25/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

protocol UIPickerFieldDataSource: AnyObject {
    func numberOfComponents(in field: UIPickerField) -> Int
    
    func numberOfRows(in compononent: Int, for field: UIPickerField) -> Int
    
    func titleForRow(_ row: Int, in component: Int, for field: UIPickerField) -> String?
}

