//
//  File.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Vapor

enum UserBuilderError: DebuggableError {
    case missingFirstName,
         missingSecondName,
         missingEmailAddress,
         missingPassword,
         missingProfilePictureKey
    
    var identifier: String {
        switch self {
        case .missingFirstName:
            return "missingFirstName"
        case .missingSecondName:
            return "missingSecondName"
        case .missingEmailAddress:
            return "missingEmailAddress"
        case .missingPassword:
            return "missingPassword"
        case .missingProfilePictureKey:
            return "missingProfilePictureKey"
        }
    }
    
    var reason: String {
        switch self {
        case .missingFirstName:
            return "Set the users first name before building"
        case .missingSecondName:
            return "Set the users second name before building"
        case .missingEmailAddress:
            return "Set the users email address before building"
        case .missingPassword:
            return "Set the users password before building"
        case .missingProfilePictureKey:
            return"Set the users profile picture key before building"
        }
    }
}
