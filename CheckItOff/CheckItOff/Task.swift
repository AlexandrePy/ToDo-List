//
//  Task.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit
import os.log

class Task: NSObject, NSCoding {
    
    //MARK: Properties
    var myName: String
    var myDescription: String?
    var myState: Bool
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("tasks")
    
    //MARK: Types
    struct PropertyKey {
        static let myPName = "name"
        static let myPDescription = "description"
        static let myPState = "state"
    }
    
    //MARK: Initialization
    init?(aName: String, aDescription: String?, aState: Bool) {
        
        // Initialization should fail if there is no name
        if aName.isEmpty {
            return nil
        }
        
        // Initialize stored properties
        self.myName = aName
        self.myDescription = aDescription
        self.myState = aState

    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(myName, forKey: PropertyKey.myPName)
        aCoder.encode(myDescription, forKey: PropertyKey.myPDescription)
        aCoder.encode(myState, forKey: PropertyKey.myPState)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        // The name is required. If we cannot decode a name string, the initializer should fail
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.myPName) as? String else {
            os_log("Unable to decode the name for a Task object", log: OSLog.default, type: .debug)
            return nil
        }

        let description = aDecoder.decodeObject(forKey: PropertyKey.myPDescription) as? String
        
        let state = aDecoder.decodeBool(forKey: PropertyKey.myPState)
        
        self.init(aName: name, aDescription: description, aState: state)
        
    }
    
}
