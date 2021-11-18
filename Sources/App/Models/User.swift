//
//  User.swift
//  
//
//  Created by Connor Black on 29/09/2021.
//

import Foundation
import Vapor
import Fluent

final class User: Model {
    
    static let schema = Tables.users.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "first_name")
    var firstName: String
    
    @Field(key: "second_name")
    var secondName: String
    
    @Field(key: "email_address")
    var emailAddress: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Field(key: "profile_picture_key")
    var profilePictureKey: String
    
    init() {}
    
    init(id: UUID? = nil,
         firstName: String,
         secondName: String,
         emailAddress: String,
         passwordHash: String,
         profilePictureKey: String) {
        self.id = id
        self.firstName = firstName
        self.secondName = secondName
        self.emailAddress = emailAddress
        self.passwordHash = passwordHash
        self.profilePictureKey = profilePictureKey
    }
}

extension User: PublicRepresentable {
    typealias T = Public
    
    var publicRepresentation: Public {
        get throws {
            .init(id: try requireID(),
                  emailAddress: emailAddress,
                  firstName: firstName,
                  secondName: secondName,
                  createdAt: createdAt,
                  updatedAt: updatedAt,
                  profilePictureKey: profilePictureKey)
        }
    }
    
    struct Public: Content {
        let id: UUID
        let emailAddress: String
        let firstName: String
        let secondName: String
        let createdAt: Date?
        let updatedAt: Date?
        let profilePictureKey: String
    }
}

extension User: ModelAuthenticatable {
    static var usernameKey = \User.$emailAddress
    static var passwordHashKey = \User.$passwordHash
    
    func verify(password: String) throws -> Bool {
        return try Bcrypt.verify(password, created: self.passwordHash)
    }
}
