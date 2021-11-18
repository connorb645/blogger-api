//
//  CreateAccessToken.swift
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
            .field("user_id", .uuid, .references(User.schema, .id), .required)
            .field("value", .string, .required)
            .field("token_type", .int, .required)
            .field("created_at", .datetime, .required)
            .field("expires_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
        
            .unique(on: "value")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Token.schema).delete()
    }
}
