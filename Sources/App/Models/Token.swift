//
//  Token.swift
//  
//
//  Created by Connor Black on 30/09/2021.
//

import Foundation
import Vapor
import Fluent

final class Token: Model {
    
    static let schema = Tables.tokens.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "user_id")
    var user: User
    
    @Field(key: "value")
    var value: String
    
    @Field(key: "token_type")
    var tokenType: TokenType
    
    @Field(key: "expires_at")
    var expiresAt: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil,
         userId: User.IDValue,
         tokenType: TokenType,
         token: String,
         expiresAt: Date) {
        self.id = id
        self.tokenType = tokenType
        self.$user.id = userId
        self.value = token
        self.expiresAt = expiresAt
    }
}

extension Token: PublicRepresentable {
    var publicRepresentation: Public {
        get throws {
            .init(value: value,
                  expiresAt: expiresAt,
                  createdAt: createdAt,
                  updatedAt: updatedAt)
        }
    }
    
    typealias T = Public
    
    struct Public: Content {
        let value: String
        let expiresAt: Date
        let createdAt: Date?
        let updatedAt: Date?
    }
}

extension Token: ModelTokenAuthenticatable {
    static let valueKey = \Token.$value
    static let userKey = \Token.$user
    
    var isValid: Bool {
        return expiresAt > Date()
    }
}
