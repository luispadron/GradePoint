//
//  AddEditClassDelegate.swift
//  GradePoint
//
//  Created by Luis Padron on 9/8/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

protocol AddEditClassDelegate: class {
    func classObjectSemesterWillbeUpdated(_ classObj: Class, from sem1: Semester, to sem2: Semester)
}
