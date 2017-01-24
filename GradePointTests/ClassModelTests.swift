//
//  ClassModelTests.swift
//  GradePoint
//
//  Created by Luis Padron on 1/23/17.
//  Copyright © 2017 Luis Padron. All rights reserved.
//

import XCTest
@testable import GradePoint
import RealmSwift

class ClassModelTests: XCTestCase {
    
    var realm: Realm?
    
    override func setUp() {
        super.setUp()
        // Setup in memory realm
        let config = Realm.Configuration(inMemoryIdentifier: "RealmTests")
        self.realm = try! Realm(configuration: config)
    }
    
    override func tearDown() {
        super.tearDown()
        // Remove any objects which were created this should happen anyway but whatever
        self.realm?.deleteAll()
    }
    
    func testInitializer() {
        let expectedName = "Test Class"
        
    }
    
}
