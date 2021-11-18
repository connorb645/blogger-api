//
//  File.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Vapor

class UserBuilder {
    
    var firstName: String?
    var secondName: String?
    var emailAddress: String?
    var password: String?
    var profilePictureKey: String?
    
    func setFirstName(to name: String) -> UserBuilder {
        self.firstName = name
        return self
    }
    
    func setSecondName(to name: String) -> UserBuilder {
        self.secondName = name
        return self
    }
    
    func setEmailAddress(to emailAddress: String) -> UserBuilder {
        self.emailAddress = emailAddress
        return self
    }
    
    func setPassword(to password: String) -> UserBuilder {
        self.password = password
        return self
    }
    
    func setProfilePictureKey(to key: String) -> UserBuilder {
        self.profilePictureKey = key
        return self
    }
    
    func build() throws -> User {
        guard let firstName = firstName else {
            throw UserBuilderError.missingFirstName
        }
        
        guard let secondName = secondName else {
            throw UserBuilderError.missingSecondName
        }
        
        guard let emailAddress = emailAddress else {
            throw UserBuilderError.missingEmailAddress
        }
        
        guard let password = password else {
            throw UserBuilderError.missingPassword
        }
        
        guard let profilePictureKey = profilePictureKey else {
            throw UserBuilderError.missingProfilePictureKey
        }
        
        let hashedPassword = try Bcrypt.hash(password)

        return .init(firstName: firstName,
                     secondName: secondName,
                     emailAddress: emailAddress,
                     passwordHash: hashedPassword,
                     profilePictureKey: profilePictureKey)
    }
    
}
