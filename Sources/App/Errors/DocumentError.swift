//
//  DocumentError.swift
//  
//
//  Created by Connor Black on 25/10/2021.
//

import Foundation

import Foundation
import Vapor

enum DocumentError: DebuggableError {
    case unsupportedFileExtension
    
    var identifier: String {
        switch self {
        case .unsupportedFileExtension: return "Unsupported_File_Extension"
        }
    }
    
    var reason: String {
        switch self {
        case .unsupportedFileExtension: return "File type is currently unsupported."
        }
    }
}
