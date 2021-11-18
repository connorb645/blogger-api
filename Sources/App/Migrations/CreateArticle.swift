//
//  CreateArticle.swift
//  
//
//  Created by Connor Black on 27/09/2021.
//

import Foundation
import Fluent
import Vapor

struct CreateArticle: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Article.schema)
            .id()
            .field("author_id", .uuid, .references(User.schema, .id), .required)
            .field("content_key", .string, .required)
            .field("title", .string, .required)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Article.schema).delete()
    }
}
