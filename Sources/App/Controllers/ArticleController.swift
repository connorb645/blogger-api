//
//  ArticleController.swift
//  
//
//  Created by Connor Black on 08/10/2021.
//

import Foundation
import Vapor
import Fluent

struct ArticleController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let articlesRoute = routes.grouped("articles")
        let bearerAuthProtected = articlesRoute.grouped(Token.authenticator())
        
        articlesRoute.get(":id", use: getArticle)
        articlesRoute.get(use: getAllArticles)
        
        bearerAuthProtected.post(use: createArticle)
        bearerAuthProtected.get("mine", use: getMyArticles)
    }
    
    private func createArticle(req: Request) async throws -> Article.Public {
        struct Body: Content {
            var title: String
            var contentKey: String
        }
        
        let user = try req.auth.require(User.self)
        
        guard let userId = user.id else {
            throw Abort(.unauthorized)
        }
                    
        let body = try req.content.decode(Body.self)
        
        let article = try ArticleBuilder().setAuthorId(to: userId)
            .setTitle(to: body.title)
            .setContentKey(to: body.contentKey)
            .build()
        
        try await article.save(on: req.db)
        
        return try article.publicRepresentation
    }
    
    private func getArticle(req: Request) async throws -> Article.Public {
        guard let idString = req.parameters.get("id") else {
            throw Abort(.badRequest)
        }
        
        guard let id = UUID(idString) else {
            throw Abort(.internalServerError)
        }
                
        let article = try await Article.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .get()
        
        guard let article = article else {
            throw Abort(.notFound)
        }
        
        return try article.publicRepresentation
    }
    
    private func getAllArticles(req: Request) async throws -> [Article.Public] {
        let articles = try await Article.query(on: req.db)
            .all()
            .get()
        
        return try articles.map { try $0.publicRepresentation }
    }
    
    private func getMyArticles(req: Request) async throws -> [Article.Public] {
        let user = try req.auth.require(User.self)
        
        guard let userId = user.id else {
            throw Abort(.unauthorized)
        }
        
        let articles = try await Article.query(on: req.db)
            .filter(\.$author.$id == userId)
            .all()
            .get()
        
        return try articles.map { try $0.publicRepresentation }
    }
}
