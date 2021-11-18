//
//  ArticleBuilder.swift
//  
//
//  Created by Connor Black on 10/11/2021.
//

import Vapor

class ArticleBuilder {
    var authorId: UUID?
    var title: String?
    var contentKey: String?
    
    func setAuthorId(to id: UUID) -> ArticleBuilder {
        self.authorId = id
        return self
    }
    
    func setTitle(to title: String) -> ArticleBuilder {
        self.title = title
        return self
    }
    
    func setContentKey(to key: String) -> ArticleBuilder {
        self.contentKey = key
        return self
    }
    
    func build() throws -> Article {
        guard let authorId = authorId else {
            throw ArticleBuilderError.missingAuthorId
        }
        
        guard let title = title else {
            throw ArticleBuilderError.missingTitle
        }
        
        guard let contentKey = contentKey else {
            throw ArticleBuilderError.missingContentKey
        }
        
        return .init(authorId: authorId,
                     title: title,
                     contentKey: contentKey)
    }
}
