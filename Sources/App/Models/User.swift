//
//  File.swift
//  
//
//  Created by Connor Black on 29/09/2021.
//

import Foundation
import Vapor
import Fluent

final class User: Model {
    struct Public: Content {
        let id: UUID
        let username: String
        let firstName: String
        let secondName: String
        let createdAt: Date?
        let updatedAt: Date?
    }
    
    static let schema = Tables.users.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: Fields.firstName.rawValue)
    var firstName: String
    
    @Field(key: Fields.secondName.rawValue)
    var secondName: String
    
    @Field(key: Fields.username.rawValue)
    var username: String
    
    @Field(key: Fields.passwordHash.rawValue)
    var passwordHash: String
    
    @Timestamp(key: Fields.createdAt.rawValue, on: .create)
    var createdAt: Date?
    
    @Timestamp(key: Fields.updatedAt.rawValue, on: .create)
    var updatedAt: Date?
    
    init() {}
    
    init(id: UUID? = nil, firstName: String, secondName: String, username: String, passwordHash: String) {
        self.id = id
        self.firstName = firstName
        self.secondName = secondName
        self.username = username
        self.passwordHash = passwordHash
    }
}

extension User {
    enum Fields: FieldKey {
        case firstName = "first_name"
        case secondName = "second_name"
        case username = "username"
        case passwordHash = "password_hash"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

extension User {
    static func create(from userSignup: UserSignup) throws -> User {
        User(firstName: userSignup.firstName,
             secondName: userSignup.secondName,
             username: userSignup.username,
             passwordHash: try Bcrypt.hash(userSignup.password))
    }
    
    func createToken(source: SessionSource) throws -> Token {
        let calendar = Calendar(identifier: .gregorian)
        let expiryDate = calendar.date(byAdding: .year, value: 1, to: Date())
        let token = [UInt8].random(count: 16).base64
        return Token(userId: try requireID(),
                         token: token,
                         source: source,
                         expiresAt: expiryDate)
    }
    
    func asPublic() throws -> User.Public {
        User.Public(id: try requireID(),
                    username: username,
                    firstName: firstName,
                    secondName: secondName,
                    createdAt: createdAt,
                    updatedAt: updatedAt)
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$username
    static var passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.passwordHash)
    }
}
