//
//  SessionController.swift
//  
//
//  Created by Connor Black on 08/10/2021.
//

import Foundation
import Vapor
import Fluent

#warning("When regenerating tokens, we currently aren't deleting stale refresh or auth tokens.")

struct SessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sessionRoute = routes.grouped("session")
        sessionRoute.post("signup", use: signup)
        sessionRoute.post("refresh-token", use: reauthenticate)
        sessionRoute.get("current-date", use: currentDate)
        
        // login
        let basicAuthProtected = sessionRoute.grouped(User.authenticator())
        basicAuthProtected.post("login", use: login)
        // current user
        let bearerAuthProtected = sessionRoute.grouped(Token.authenticator())
        bearerAuthProtected.get("token", use: token)
        
    }
    
    private func signup(req: Request) async throws -> NewSession {
        
        #warning("We should probs remove all the user creation logic from here and into the UserController, then call the function from here")
        
        struct Body: Content, Validatable {
            var emailAddress: String
            let password: String
            let firstName: String
            let secondName: String
            
            static func validations(_ validations: inout Validations) {
                validations.add("emailAddress", as: String.self, is: !.empty)
                validations.add("password", as: String.self, is: .count(6...))
            }
        }
        
        try Body.validate(content: req)
        
        let body = try req.content.decode(Body.self)
            
        let userExists = try await userExists(body.emailAddress, req: req)
        
        guard !userExists else {
            throw UserError.alreadyExists
        }
        
        //Create an identicon for the user based on the email address
        let identiconGenerator = IdenticonGenerator(req: req)
        let identiconData = try await identiconGenerator.generate(for: body.emailAddress)
        
        // Force the content type to be .svg, since that's what the identicon will create for us.
        req.headers.contentType = .svg
        
        // Upload the identicon to our public storage
        let fileMetaGenerator = try FileMetaGenerator(req: req)
        let documentService = DocumentService(req: req)
        let fileKey = fileMetaGenerator.key
        let profileImageKey = try await documentService.upload(data: identiconData, withFileKey: fileKey)
        
        // Build the user object
        let user = try UserBuilder().setFirstName(to: body.firstName)
            .setSecondName(to: body.secondName)
            .setPassword(to: body.password)
            .setEmailAddress(to: body.emailAddress)
            .setProfilePictureKey(to: profileImageKey)
            .build()
        
        try await user.save(on: req.db)
        
        let userId = try user.requireID()
        
        // Build the new session token object
        let newAccessToken = try TokenBuilder()
            .setUserId(to: userId)
            .setTokenType(to: .access)
            .build()
        
        let newRefreshToken = try TokenBuilder()
            .setUserId(to: userId)
            .setTokenType(to: .refresh)
            .build()
                
        
        try await newAccessToken.save(on: req.db)
        try await newRefreshToken.save(on: req.db)
        
        let publicUser = try user.publicRepresentation
                
        return NewSession(accessToken: newAccessToken.value,
                          refreshToken: newRefreshToken.value,
                          accessTokenExpiry: newAccessToken.expiresAt,
                          user: publicUser)
    }
    
    private func login(req: Request) async throws -> NewSession {
        let user = try req.auth.require(User.self)
        
        let userId = try user.requireID()
        
        // Build the new session token object
        let newAccessToken = try TokenBuilder()
            .setUserId(to: userId)
            .setTokenType(to: .access)
            .build()
        
        let newRefreshToken = try TokenBuilder()
            .setUserId(to: userId)
            .setTokenType(to: .refresh)
            .build()
                
        try await newAccessToken.save(on: req.db)
        try await newRefreshToken.save(on: req.db)
        
        let publicUser = try user.publicRepresentation
                
        return NewSession(accessToken: newAccessToken.value,
                          refreshToken: newRefreshToken.value,
                          accessTokenExpiry: newAccessToken.expiresAt,
                          user: publicUser)
    }
    
    private func token(req: Request) throws -> Token.Public {
        return try req.auth.require(Token.self).publicRepresentation
    }
    
    private func reauthenticate(req: Request) async throws -> NewSession {
        struct Body: Content {
            let refreshToken: String
        }
        
        let body = try req.content.decode(Body.self)
        
        let token = try await Token.query(on: req.db)
            .filter(\.$value == body.refreshToken)
            .filter(\.$tokenType == TokenType.refresh)
            .first()
            .get()
        
        guard let token = token else {
            throw Abort(.unauthorized)
        }
                
        guard token.isValid else {
            throw Abort(.unauthorized)
        }
        
        let user = try await token.$user.get(on: req.db)
        let userId = try user.requireID()
        
        let newAccessToken = try TokenBuilder()
            .setUserId(to: userId)
            .setTokenType(to: .access)
            .build()
        
        let newRefreshToken = try TokenBuilder()
            .setUserId(to: userId)
            .setTokenType(to: .refresh)
            .build()
        
        try await newAccessToken.save(on: req.db)
        try await newRefreshToken.save(on: req.db)
        
        let publicUser = try user.publicRepresentation
                
        return NewSession(accessToken: newAccessToken.value,
                          refreshToken: newRefreshToken.value,
                          accessTokenExpiry: newAccessToken.expiresAt,
                          user: publicUser)
    }
    
    private func userExists(_ emailAddress: String, req: Request) async throws -> Bool {
        let user = try await User.query(on: req.db)
            .filter(\.$emailAddress == emailAddress)
            .first()
        
        return user != nil
    }
    
    private func currentDate(req: Request) throws -> TrueDate {
        TrueDate(current: Date())
    }
}

struct TrueDate: Content {
    let current: Date
}

struct NewSession: Content {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiry: Date
    let user: User.Public
}
