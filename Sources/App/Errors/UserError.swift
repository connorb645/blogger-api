//
//  UserError.swift
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
        case .alreadyExists: return "AlreadyExists"
        }
    }
    
    var reason: String {
        switch self {
        case .alreadyExists: return "That username is already taken."
        }
    }
}
