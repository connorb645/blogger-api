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
            .field(Article.Fields.authorId.rawValue, .uuid, .references(User.schema, .id))
            .field(Article.Fields.contentId.rawValue, .uuid, .references(Document.schema, .id))
            .field(Article.Fields.title.rawValue, .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Article.schema).delete()
    }
}
