//
//  UserController.swift
//  
//
//  Created by Connor Black on 27/10/2021.
//

import Foundation
import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let userRoute = routes.grouped("users")
        userRoute.get(":id", use: getUser)
        userRoute.get(":id", "articles", use: getUsersArticles)
    
        let bearerAuthProtected = userRoute.grouped(Token.authenticator())
        bearerAuthProtected.get("current", use: current)
    }
    
    private func current(req: Request) throws -> User.Public {
        try req.auth.require(User.self).publicRepresentation
    }
    
    private func getUser(req: Request) async throws -> User.Public {
        let user = try await User.find(req.parameters.get("id"), on: req.db)
        
        guard let user = user else {
            throw Abort(.notFound)
        }
        
        return try user.publicRepresentation
    }
    
    private func getUsersArticles(req: Request) async throws -> [Article.Public] {
        
        guard let userId = req.parameters.get("id"),
              let userUUID = UUID(userId) else {
            throw Abort(.notFound)
        }
            
        return try await Article.query(on: req.db)
            .filter(\.$author.$id == userUUID)
            .all()
            .get()
            .map { try $0.publicRepresentation }
    }
}
