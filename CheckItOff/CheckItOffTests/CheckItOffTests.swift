//
//  CheckItOffTests.swift
//  CheckItOffTests
//
//  Created by Robinson Prada Mejia on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import XCTest
@testable import CheckItOff

class CheckItOffTests: XCTestCase {
    
    //MARK: Test Class Tests
    
    // Confirm that the Task initializer returns a Task object when passed valid parameters
    func testTaskInitializiationSucceeds() {
        
        // No description
        let noDescriptionTask = Task.init(name: "noDescription", description: nil)
        XCTAssertNotNil(noDescriptionTask)
    
        // With a description
        let aDescriptionTask = Task.init(name: "aDescription", description: "I do have a description.")
        XCTAssertNotNil(aDescriptionTask)
        
    }
    
    // Confirm that the Task initializer returns nil when passed an empty name
    func testTaskInitializationFails() {
        // No name
        let noNameTask = Task.init(name: "", description: nil)
        XCTAssertNil(noNameTask)
    }
    
}
