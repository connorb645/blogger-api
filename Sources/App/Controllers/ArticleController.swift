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
    
    private func createArticle(req: Request) throws -> EventLoopFuture<Article.Public> {
        let user = try req.auth.require(User.self)
        
        guard let userId = user.id else {
            return req.eventLoop.future(error: Abort(.unauthorized))
        }
                    
        let articleCreation = try req.content.decode(Article.Creation.self)
        
        let newBlogPost = try Article.create(with: articleCreation, authorId: userId)
        
        return newBlogPost.save(on: req.db)
            .flatMapThrowing {
                return try newBlogPost.asPublic()
            }
    }
    
    private func getArticle(req: Request) throws -> EventLoopFuture<Article.Public> {
        guard let idString = req.parameters.get("id") else {
            return req.eventLoop.future(error: Abort(.badRequest))
        }
        
        guard let id = UUID(idString) else {
            return req.eventLoop.future(error: Abort(.internalServerError))
        }
                
        return Article.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { unwrappedArticle in
                return try unwrappedArticle.asPublic()
            }
    }
    
    private func getAllArticles(req: Request) throws -> EventLoopFuture<[Article.Public]> {
        Article.query(on: req.db)
            .all()
            .flatMapThrowing { articles in
                return try articles.map { try $0.asPublic() }
            }
    }
    
    private func getMyArticles(req: Request) throws -> EventLoopFuture<[Article.Public]> {
        let user = try req.auth.require(User.self)
        
        guard let userId = user.id else {
            return req.eventLoop.future(error: Abort(.unauthorized))
        }
        
        return Article.query(on: req.db)
            .filter(\.$author.$id == userId)
            .all()
            .flatMapThrowing { blogPosts in
                return try blogPosts.map { try $0.asPublic() }
            }
    }
}
