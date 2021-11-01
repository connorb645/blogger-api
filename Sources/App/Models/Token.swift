//
//  Token.swift
//  
//
//  Created by Connor Black on 30/09/2021.
//

import Foundation
import Vapor
import Fluent

enum SessionSource: Int, Content {
    case signup
    case login
}

final class Token: Model {
    
    struct Public: Content {
        let value: String
        let expiresAt: Date?
        let createdAt: Date?
    }
    
    static let schema = Tables.tokens.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: Fields.userId.rawValue)
    var user: User
    
    @Field(key: Fields.value.rawValue)
    var value: String
    
    @Field(key: Fields.source.rawValue)
    var source: SessionSource
    
    @Field(key: Fields.expiresAt.rawValue)
    var expiresAt: Date?
    
    @Timestamp(key: Fields.createdAt.rawValue, on: .create)
    var createdAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, userId: User.IDValue, token: String, source: SessionSource, expiresAt: Date?) {
        self.id = id
        self.$user.id = userId
        self.value = token
        self.source = source
        self.expiresAt = expiresAt
    }
}

extension Token {
    enum Fields: FieldKey {
        case userId = "user_id"
        case value = "value"
        case source = "source"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    
    var isValid: Bool {
        guard let expiryDate = expiresAt else {
            return true
        }
        return expiryDate > Date()
    }
}

extension Token {
    func asPublic() -> Token.Public {
        Token.Public(value: self.value,
                     expiresAt: self.expiresAt,
                     createdAt: self.createdAt)
    }
}
