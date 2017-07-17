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
    lazy var realm: Realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "ModelTests"))
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
}
