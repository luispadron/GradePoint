//
//  AssignmentChangesListener.swift
//  GradePoint
//
//  Created by Luis Padron on 9/9/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

protocol AssignmentChangesListener: AnyObject {
    func assignmentWasCreated(_ assignment: Assignment)
    func assignmentRubricWasUpdated(_ assignment: Assignment, from rubric1: Rubric, to rubric2: Rubric)
    func assignmentWasUpdated(_ assignment: Assignment)
}
