//
//  File.swift
//  
//
//  Created by Connor Black on 11/10/2021.
//

import Foundation
import Vapor

enum UserError: DebuggableError {
    case alreadyExists
    
    var identifier: String {
        switch self {
        case .alreadyExists: return "User already exists"
        }
    }
    
    var reason: String {
        switch self {
        case .alreadyExists: return "User already exists."
        }
    }
}
