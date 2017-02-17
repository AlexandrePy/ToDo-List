//
//  CheckItOffTests.swift
//  CheckItOffTests
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import XCTest
@testable import CheckItOff

class CheckItOffTests: XCTestCase {
    
    //MARK: Test Class Tests
    
    // Confirm that the Task initializer returns a Task object when passed valid parameters
    func testTaskInitializiationSucceeds() {
        
        // No description
        let noDescriptionTask = Task.init(aName: "noDescription", aDescription: nil, aState: false)
        XCTAssertNotNil(noDescriptionTask)
    
        // With a description
        let aDescriptionTask = Task.init(aName: "aDescription", aDescription: "I do have a description.", aState: false)
        XCTAssertNotNil(aDescriptionTask)
        
    }
    
    // Confirm that the Task initializer returns nil when passed an empty name
    func testTaskInitializationFails() {
        // No name
        let noNameTask = Task.init(aName: "", aDescription: nil, aState: false)
        XCTAssertNil(noNameTask)
    }
    
    
    // Confirm that the List initializer returns a List object when passed valid parameters
    func testListInitializationSucceeds() {
        
        // Empty list
        let notask = [Task]()
        let emptyList = List.init(aName: "emptyList", someTasks: notask)
        XCTAssertNotNil(emptyList)
        
        // With a some tasks
        let task1 = Task(aName: "task1", aDescription: "I'm task1", aState: false)
        let task2 = Task(aName: "task2", aDescription: "I'm task2", aState: false)
        let tasks : [Task] = [task1!,task2!]
        let someTasksList = List.init(aName: "someTaskList", someTasks: tasks)
        XCTAssertNotNil(someTasksList)
        
    }
    
    // Confirm that the List initializer returns nil when passed an empty name
    func testListInitializationFails() {
        // No name
        let notask = [Task]()
        let noNameList = List.init(aName: "", someTasks: notask)
        XCTAssertNil(noNameList)
    }
    
}
