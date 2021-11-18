//
//  CreateUser.swift
//  
//
//  Created by Connor Black on 29/09/2021.
//

import Foundation
import Fluent
import Vapor

struct CreateUser: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema)
            .id()
            .field("first_name", .string, .required)
            .field("second_name", .string, .required)
            .field("email_address", .string, .required)
            .field("password_hash", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .field("profile_picture_key", .string, .required)
        
            .unique(on: "email_address")
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
