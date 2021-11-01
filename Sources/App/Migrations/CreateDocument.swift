//
//  CreateDocument.swift
//  
//
//  Created by Connor Black on 23/10/2021.
//

import Foundation

import Foundation
import Fluent
import Vapor

struct CreateDocument: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Document.schema)
            .id()
            .field(Document.Fields.documentName.rawValue, .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Document.schema).delete()
    }
}
