//
//  CreateToken.swift
//  
//
//  Created by Connor Black on 30/09/2021.
//

import Foundation
import Fluent
import Vapor

struct CreateToken: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema)
            .id()
            .field(Token.Fields.userId.rawValue, .uuid, .references(User.schema, .id))
            .field(Token.Fields.value.rawValue, .string, .required)
            .unique(on: Token.Fields.value.rawValue)
            .field(Token.Fields.source.rawValue, .int, .required)
            .field(Token.Fields.createdAt.rawValue, .datetime, .required)
            .field(Token.Fields.expiresAt.rawValue, .datetime)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}
