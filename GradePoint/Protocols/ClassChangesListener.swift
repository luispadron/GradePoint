//
//  ClassChangesListener.swift
//  GradePoint
//
//  Created by Luis Padron on 9/8/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

protocol ClassChangesListener: AnyObject {
    func classWasCreated(_ classObj: Class)
    func classSemesterWasUpdated(_ classObj: Class, from sem1: Semester, to sem2: Semester)
    func classWasUpdated(_ clasObj: Class)
}
