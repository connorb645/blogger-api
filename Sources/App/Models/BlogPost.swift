//
//  File.swift
//  
//
//  Created by Connor Black on 27/09/2021.
//

import Foundation
import Vapor
import Fluent

final class BlogPost: Model, Content {
    
    struct Creation: Content {
        var title: String
    }
    
    struct Public: Content {
        var id: UUID
        var title: String
        var authorId: UUID
    }
    
    static let schema = Tables.blogPosts.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: Fields.authorId.rawValue)
    var author: User
    
    @Field(key: Fields.title.rawValue)
    var title: String
    
    init() {}
    
    init(id: UUID? = nil, authorId: User.IDValue, title: String) {
        self.id = id
        self.title = title
        self.$author.id = authorId
    }
}

extension BlogPost {
    static func create(with blogPostCreation: BlogPost.Creation, authorId: UUID) throws -> BlogPost {
        BlogPost(authorId: authorId, title: blogPostCreation.title)
    }
    
    func asPublic() throws -> BlogPost.Public {
        BlogPost.Public(id: try requireID(),
                        title: title,
                        authorId: $author.id)
    }
}

extension BlogPost {
    enum Fields: FieldKey {
        case title = "title"
        case authorId = "author_id"
    }
}
