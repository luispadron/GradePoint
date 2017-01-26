//
//  ModelTests.swift
//  GradePoint
//
//  Created by Luis Padron on 1/23/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import XCTest
@testable import GradePoint
import RealmSwift

class ModelTests: XCTestCase {
    
    // In memory realm
    lazy var realm: Realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "RealmTests"))
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: - Class
    
    func testClassModelInitializer() {
        // Create the semester object
        let expectedSemester = Semester(withTerm: "Spring", andYear: 2017)
        // Create the rubric object
        let expectedRubric1 = Rubric(withName: "Rubric 1", andWeight: 50)
        let expectedRubric2 = Rubric(withName: "Rubric 2", andWeight: 50)
        let rubricList = List<Rubric>([expectedRubric1, expectedRubric2])
        // Create class object
        let classObj = Class(withName: "Test Class", inSemester: expectedSemester, withRubrics: rubricList)
        
        // Do the tests
        XCTAssertNotNil(classObj.id)
        XCTAssertEqual(classObj.name, "Test Class")
        XCTAssertEqual(classObj.semester, expectedSemester)
        XCTAssertEqual(classObj.rubrics, rubricList)
        XCTAssertNotNil(classObj.colorData)
        XCTAssertEqual(classObj.assignments.count, 0)
    }
    
    func testClassModelPersistance() {
        writeClassToRealm()
        
        guard let classObj = realm.objects(Class.self).first else {
            XCTFail("Failed to get class object from Realm")
            return
        }
        
        // Test the created object
        XCTAssertNotNil(classObj.id)
        XCTAssertEqual(classObj.name, "Test Class")
        // Semester check
        XCTAssertNotNil(classObj.semester)
        // Color check
        XCTAssertNotNil(classObj.colorData)
        XCTAssertNotNil(NSKeyedUnarchiver.unarchiveObject(with: classObj.colorData) as? UIColor)
        // Rubric check
        XCTAssertEqual(classObj.rubrics.count, 2)
        XCTAssertNotEqual(classObj.rubrics[0], classObj.rubrics[1])
        XCTAssertNotEqual(classObj.rubrics[0].name, classObj.rubrics[1].name)
        XCTAssertEqual(classObj.rubrics[0].parentClass.first, classObj)
        XCTAssertEqual(classObj.rubrics[1].parentClass.first, classObj)
        // Assignment check
        XCTAssertEqual(classObj.assignments.count, 2)
        XCTAssertNotEqual(classObj.assignments[0], classObj.assignments[1])
        XCTAssertNotEqual(classObj.assignments[0].name, classObj.assignments[1].name)
        XCTAssertEqual(classObj.assignments[0].parentClass.first, classObj)
        XCTAssertEqual(classObj.assignments[1].parentClass.first, classObj)
        
        deleteObjects()
    }
    
    // MARK: - Assignments
    
    func testAssignmentModelInitializer() {
        let date = Date()
        let rubric = Rubric(withName: "Rubric 1", andWeight: 100)
        let assignment = Assignment(name: "Assignment 1", date: date, score: 80, associatedRubric: rubric)
        
        XCTAssertNotNil(assignment.id)
        XCTAssertEqual(assignment.name, "Assignment 1")
        XCTAssertEqual(assignment.date, date)
        XCTAssertEqual(assignment.score, 80)
        XCTAssertEqual(assignment.associatedRubric, rubric)
        XCTAssertNil(assignment.parentClass.first, "Was created without parent, thus nil")
    }
    
    func testAssignmentWhenRubricIsUpdated() {
        writeClassToRealm()
        
        guard let classObj = realm.objects(Class.self).first else {
            XCTFail("Couldn't get class object from realm")
            return
        }
        
        // Update the rubric, this should still keep the associatedRubric inside of the assignment instance
        let assignment = classObj.assignments.filter("name = 'Assignment 1'").first!
        
        XCTAssertNotNil(assignment.associatedRubric)
        
        let rubricForAssignment = assignment.associatedRubric!
        
        // Make sure its what we expect first
        XCTAssertEqual(assignment.name, "Assignment 1")
        XCTAssertEqual(rubricForAssignment.name, "Rubric 1")
        
        // Update rubric
        try! realm.write {
            rubricForAssignment.name = "Updated rubric 1"
        }
        
        // Make sure kept relationship
        XCTAssertEqual(rubricForAssignment.name, "Updated rubric 1")
        XCTAssertNotNil(assignment.associatedRubric)
        XCTAssertEqual(assignment.associatedRubric, rubricForAssignment)
        
        deleteObjects()
    }
    
    func testAssignmentWhenClassIsUpdated() {
        writeClassToRealm()
        
        guard let classObj = realm.objects(Class.self).first else {
            XCTFail("Couldn't get class object from realm")
            return
        }
        
        // Again make sure when updating the class, that the relationships stay together
        let newName = "Class 1 Updated"
        let newRubricName = "Rubric 1 Updated"
        let newRubricWeight = 60.0
        let newRubricWeight2 = 40.0
    
        
        try! realm.write {
            classObj.name = newName
            classObj.rubrics[0].name = newRubricName
            classObj.rubrics[0].weight = newRubricWeight
            classObj.rubrics[1].weight = newRubricWeight2
        }
        
        XCTAssertEqual(classObj.assignments[0].associatedRubric, classObj.rubrics[0])
        XCTAssertEqual(classObj.assignments[1].associatedRubric, classObj.rubrics[1])
        XCTAssertEqual(classObj.assignments[0].parentClass.first, classObj)
        
        deleteObjects()
    }
    
    func testAssignmentQueryingForRubricAfterUpdatingRubrics() {
        writeClassToRealm()
        
        guard let classObj = realm.objects(Class.self).first else {
            XCTFail("Couldn't get class object from realm")
            return
        }
        
        // Test normal query before update
        let rubric = classObj.rubrics[0]
        let assignmentsForRubric = realm.objects(Assignment.self).filter("associatedRubric = %@", rubric)
        // Should be 1
        XCTAssertEqual(assignmentsForRubric.count, 1)
        XCTAssertEqual(assignmentsForRubric[0].associatedRubric, rubric)
        XCTAssertEqual(assignmentsForRubric[0].parentClass.first, classObj)
        
        // Now update the rubric and write it to realm, then check if query passes as well
        try! realm.write {
            rubric.name = "Updated rubric"
            rubric.weight = 60
        }
        
        // Check rubric
        XCTAssertEqual(rubric.name, "Updated rubric")
        XCTAssertEqual(rubric.weight, 60)
        // Check association to class
        XCTAssertEqual(rubric.parentClass.first, classObj)
        // Check association with assignment via query
        let name = assignmentsForRubric[0].name
        let newAssignmentsForRubric = realm.objects(Assignment.self).filter("associatedRubric = %@", rubric)
        XCTAssertEqual(newAssignmentsForRubric[0].name, name)
        XCTAssertEqual(newAssignmentsForRubric[0].associatedRubric, rubric)
        XCTAssertEqual(newAssignmentsForRubric[0], assignmentsForRubric[0])
        
        deleteObjects()
    }
    
    // MARK: - Helper methods
    
    func writeClassToRealm() {
        // Create the semester object
        let expectedSemester = Semester(withTerm: "Spring", andYear: 2017)
        // Create the rubric object
        let expectedRubric1 = Rubric(withName: "Rubric 1", andWeight: 50)
        let expectedRubric2 = Rubric(withName: "Rubric 2", andWeight: 50)
        let rubricList = List<Rubric>([expectedRubric1, expectedRubric2])
        let assignment1 = Assignment(name: "Assignment 1", date: Date(), score: 80, associatedRubric: expectedRubric1)
        let assignment2 = Assignment(name: "Assignment 2", date: Date(), score: 100, associatedRubric: expectedRubric2)
        // Create class object
        let classObj = Class(withName: "Test Class", inSemester: expectedSemester, withRubrics: rubricList)
        classObj.assignments.append(contentsOf: [assignment1, assignment2])
        // Write to realm
        try! realm.write {
            realm.create(Class.self, value: classObj, update: true)
        }
    }
    
    func deleteObjects() {
        try! realm.write {
            self.realm.deleteAll()
        }
    }
}
