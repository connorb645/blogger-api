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
    
    struct Creation: Content {
        var title: String
        var contentId: UUID
    }
    
    struct Public: Content {
        var id: UUID
        var title: String
        var authorId: UUID
        var contentId: UUID
    }
    
    static let schema = Tables.articles.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: Fields.authorId.rawValue)
    var author: User
    
    @Field(key: Fields.title.rawValue)
    var title: String
    
    @Parent(key: Fields.contentId.rawValue)
    var content: Document
    
    init() {}
    
    init(id: UUID? = nil,
         authorId: User.IDValue,
         title: String,
         contentId: Document.IDValue) {
        self.id = id
        self.title = title
        self.$author.id = authorId
        self.$content.id = contentId
    }
}

extension Article {
    static func create(with blogPostCreation: Article.Creation,
                       authorId: UUID) throws -> Article {
        Article(authorId: authorId,
                title: blogPostCreation.title,
                contentId: blogPostCreation.contentId)
    }
    
    func asPublic() throws -> Article.Public {
        Article.Public(id: try requireID(),
                       title: title,
                       authorId: $author.id,
                       contentId: $content.id)
    }
}

extension Article {
    enum Fields: FieldKey {
        case title = "title"
        case authorId = "author_id"
        case contentId = "content_id"
    }
}
