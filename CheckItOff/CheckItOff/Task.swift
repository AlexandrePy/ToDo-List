//
//  Task.swift
//  CheckItOff
//
//  Created by Alexandre Proy on 07/02/17.
//  Copyright © 2017 AlexandrePy. All rights reserved.
//

import UIKit
import os.log

class Task {
    
    //MARK: Properties
    var myName: String
    var myDescription: String?
    var myState: Bool
    
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
    
}
