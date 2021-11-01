//
//  SessionController.swift
//  
//
//  Created by Connor Black on 08/10/2021.
//

import Foundation
import Vapor
import Fluent

struct SessionController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sessionRoute = routes.grouped("session")
        sessionRoute.post("signup", use: signup)
        // login
        let basicAuthProtected = sessionRoute.grouped(User.authenticator())
        basicAuthProtected.post("login", use: login)
        // current user
        let bearerAuthProtected = sessionRoute.grouped(Token.authenticator())
        bearerAuthProtected.get("current-user", use: current)
        bearerAuthProtected.get("token", use: token)
    }
    
    private func signup(req: Request) throws -> EventLoopFuture<NewSession> {
        try UserSignup.validate(content: req)
        var userSignup = try req.content.decode(UserSignup.self)
        
        userSignup.normalize()
        
        let user = try User.create(from: userSignup)
        var token: Token!
        
        return userExists(userSignup.emailAddress, req: req)
            .flatMap { exists in
                guard !exists else {
                    return req.eventLoop.future(error: UserError.alreadyExists)
                }
                
                return user.save(on: req.db)
            }.flatMap {
                guard let newToken = try? user.createToken(source: .signup) else {
                    return req.eventLoop.future(error: Abort(.internalServerError))
                }
                
                token = newToken
                return token.save(on: req.db)
            }.flatMapThrowing {
                NewSession(token: token.value, user: try user.asPublic())
            }
            
    }
    
    private func login(req: Request) throws -> EventLoopFuture<NewSession> {
        let user = try req.auth.require(User.self)
        let token = try user.createToken(source: .login)
        
        return token.save(on: req.db).flatMapThrowing {
            NewSession(token: token.value, user: try user.asPublic())
        }
    }
    
    private func current(req: Request) throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }
    
    private func token(req: Request) throws -> Token.Public {
        return try req.auth.require(Token.self).asPublic()
    }
    
    private func userExists(_ emailAddress: String, req: Request) -> EventLoopFuture<Bool> {
        User.query(on: req.db)
            .filter(\.$emailAddress == emailAddress)
            .first()
            .map { $0 != nil }
    }
}

struct UserSignup: Content {
    var emailAddress: String
    let password: String
    let firstName: String
    let secondName: String
    
    mutating func normalize() {
        emailAddress = emailAddress.lowercased()
    }
}

extension UserSignup: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("emailAddress", as: String.self, is: !.empty)
        validations.add("password", as: String.self, is: .count(6...))
    }
}

struct NewSession: Content {
    let token: String
    let user: User.Public
}
