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
        try req.auth.require(User.self).asPublic()
    }
    
    private func getUser(req: Request) throws -> EventLoopFuture<User.Public> {
        return User.find(req.parameters.get("id"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { try $0.asPublic() }
    }
    
    private func getUsersArticles(req: Request) throws -> EventLoopFuture<[Article.Public]> {
        
        guard let userId = req.parameters.get("id"),
              let userUUID = UUID(userId) else {
            throw Abort(.notFound)
        }
            
        return Article.query(on: req.db)
            .filter(\.$author.$id == userUUID)
            .all()
            .flatMapThrowing { articles in
                try articles.map {
                    try $0.asPublic()
                }
            }
        
    }
}
