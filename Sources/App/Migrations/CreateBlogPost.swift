//
//  File.swift
//  
//
//  Created by Connor Black on 27/09/2021.
//

import Foundation
import Fluent
import Vapor

struct CreateBlogPost: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(BlogPost.schema)
            .id()
            .field(BlogPost.Fields.authorId.rawValue, .uuid, .references(User.schema, .id))
            .field(BlogPost.Fields.title.rawValue, .string)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(BlogPost.schema).delete()
    }
}
