//
//  ClassesTableViewUITests.swift
//  GradePointUITests
//
//  Created by Luis Padron on 7/15/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import XCTest

class ClassesTableViewUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
    }

    /// Tests the onboarding the user will see when first running the app
    func test_A_Onboarding() {
        // Launch with a clear state and no animations
        let app = XCUIApplication()
        app.launchArguments = ["ClearState", "NoAnimations"]
        app.launch()
        
        let window = app.windows.firstMatch
        window.swipeLeft()
        window.swipeLeft()

        app.buttons["College"].tap()
        app.buttons["A+"].tap()
        window.swipeLeft()

        let button = app.buttons["Cool, lets start!"]
        waitForElementToAppear(element: button, timeout: 5.0)
        button.tap()
        let table = app.tables.firstMatch
        waitForElementToAppear(element: table, timeout: 5.0)
    }
    
    /// Tests adding classes to the tableview for an inital class count of zero
    func test_B_AddClasses() {
        
        let app = XCUIApplication()
        app.launchArguments = []
        app.launch()
        
        // Initially zero
        XCTAssertEqual(app.tables.cells.count, 0)
        
        // Adds an in progress class with two rubrics
        app.navigationBars["Classes"].buttons["Add"].tap()
        
        let scrollViewsQuery = app.scrollViews
        let elementsQuery = scrollViewsQuery.otherElements
        let classNameTextField = elementsQuery.textFields["Class Name"]
        classNameTextField.tap()
        classNameTextField.typeText("in progress class")
        
        let addAGradeSectionStaticText = elementsQuery.staticTexts["Add a grade section"]
        addAGradeSectionStaticText.tap()
        
        let nameTextField = elementsQuery.textFields["Name"]
        nameTextField.tap()
        nameTextField.typeText("rubric 1")
        
        let weightTextField = elementsQuery.textFields["Weight"]
        weightTextField.tap()
        weightTextField.typeText("50")
        addAGradeSectionStaticText.tap()
        
        let element = scrollViewsQuery.children(matching: .other).element.children(matching: .other).element(boundBy: 7)
        let nameTextField2 = element.textFields["Name"]
        nameTextField2.tap()
        nameTextField2.typeText("rubric 2")
        
        let weightTextField2 = element.textFields["Weight"]
        weightTextField2.tap()
        weightTextField2.tap()
        weightTextField2.typeText("50")
        app.buttons["Save"].tap()
        
        // Should have one cell in the table view now
        XCTAssertEqual(app.tables.cells.count, 1)
        
        // Adds a previous class
        app.navigationBars["Classes"].buttons["Add"].tap()
        
        elementsQuery.buttons["Previous class"].tap()
        classNameTextField.tap()
        classNameTextField.typeText("previous class")
        app.buttons["Save"].tap()
        
        // Now 2 cells
        XCTAssertEqual(app.tables.cells.count, 2)
    }

    func test_C_search() {
        let app = XCUIApplication()
        app.launch()
        app.windows.firstMatch.swipeDown()

        let searchClassesSearchField = app.searchFields["Search"]
        searchClassesSearchField.tap()
        searchClassesSearchField.typeText("in progress")

        XCTAssertEqual(app.tables.cells.count, 1)
    }

    func test_D_Favorite() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertEqual(app.tables.cells.count, 2)

        // Test favoriting
        if #available(iOS 11.0, *) {
            app.tables.cells.firstMatch.swipeRight()
        } else {
            app.tables.cells.firstMatch.swipeLeft()
        }

        XCUIApplication().tables.cells.buttons["Favorite"].tap()
        let cell = app.tables.cells.element(boundBy: 0)
        waitForElementToAppear(element: cell, timeout: 2.0)

        XCTAssertEqual(app.tables.cells.count, 3)

        // Test unfavoriting
        if #available(iOS 11.0, *) {
            app.tables.cells.firstMatch.swipeRight()
        } else {
            app.tables.cells.firstMatch.swipeLeft()
        }

        XCUIApplication().tables.buttons["Favorite"].tap()
        waitForElementToAppear(element: cell, timeout: 2.0)
        XCTAssertEqual(app.tables.cells.count, 2)
    }

    func test_E_ClassesDeletion() {
        let app = XCUIApplication()
        app.launch()

        // Test full deltion

        XCTAssertEqual(app.tables.cells.count, 2)

        app.tables.cells.element(boundBy: 1).swipeLeft()
        app.tables.cells.buttons["Delete"].tap()

        XCTAssertEqual(app.tables.cells.count, 1)
        XCTAssert(app.buttons["UNDO"].exists)

        // Wait for first undo to get removed
        sleep(3)

        // Test undo
        app.tables.cells.firstMatch.swipeLeft()
        app.tables.cells.buttons["Delete"].tap()
        XCTAssertEqual(app.tables.cells.count, 0)
        app.buttons["UNDO"].tap()

        XCTAssertEqual(app.tables.cells.count, 1)
    }
    
}

extension ClassesTableViewUITests {
    func waitForElementToAppear(element: XCUIElement, timeout: TimeInterval = 5,  file: String = #file, line: Int = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")

        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)

        waitForExpectations(timeout: timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
}
