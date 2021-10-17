//
//  File.swift
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
            .field(User.Fields.firstName.rawValue, .string, .required)
            .field(User.Fields.secondName.rawValue, .string, .required)
            .field(User.Fields.username.rawValue, .string, .required)
            .unique(on: User.Fields.username.rawValue)
            .field(User.Fields.passwordHash.rawValue, .string, .required)
            .field(User.Fields.createdAt.rawValue, .datetime, .required)
            .field(User.Fields.updatedAt.rawValue, .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(User.schema).delete()
    }
}
