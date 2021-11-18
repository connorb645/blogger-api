//
//  File.swift
//  
//
//  Created by Connor Black on 10/11/2021.
//

import Vapor

enum ArticleBuilderError: DebuggableError {
    case missingAuthorId,
         missingTitle,
         missingContentKey
    
    var identifier: String {
        switch self {
        case .missingAuthorId:
            return "missingAuthorId"
        case .missingTitle:
            return "missingTitle"
        case .missingContentKey:
            return "missingContentKey"
        }
    }
    
    var reason: String {
        switch self {
        case .missingAuthorId:
            return "Set the author ID before building"
        case .missingTitle:
            return "Set the article title before building"
        case .missingContentKey:
            return "Set the content key before building"
        }
    }
}
