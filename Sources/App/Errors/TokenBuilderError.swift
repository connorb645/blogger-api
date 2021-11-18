//
//  File.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Vapor

enum TokenBuilderError: DebuggableError {
    case missingUserId,
         missingTokenType,
         expiryDateCreation
    
    var identifier: String {
        switch self {
        case .missingUserId:
            return "missingUserId"
        case .missingTokenType:
            return "missingTokenType"
        case .expiryDateCreation:
            return "expiryDateCreation"
        }
    }
    
    var reason: String {
        switch self {
        case .missingUserId:
            return "Set the users ID before building"
        case .missingTokenType:
            return "Set the token type before building"
        case .expiryDateCreation:
            return "Failure generating an expiry date"
        }
    }
}
