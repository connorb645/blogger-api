//
//  Article.swift
//  
//
//  Created by Connor Black on 27/09/2021.
//

import Foundation
import Vapor
import Fluent

final class Article: Model, Content {
    
    static let schema = Tables.articles.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "author_id")
    var author: User
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content_key")
    var contentKey: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil,
         authorId: User.IDValue,
         title: String,
         contentKey: String) {
        self.id = id
        self.title = title
        self.$author.id = authorId
        self.contentKey = contentKey
    }
}

extension Article: PublicRepresentable {
    var publicRepresentation: Public {
        get throws {
            .init(id: try requireID(),
                  title: title,
                  authorId: $author.id,
                  contentKey: contentKey,
                  createdAt: createdAt,
                  updatedAt: updatedAt)
        }
    }
    
    typealias T = Public
    
    struct Public: Content {
        var id: UUID
        var title: String
        var authorId: UUID
        var contentKey: String
        var createdAt: Date?
        var updatedAt: Date?
    }
}
