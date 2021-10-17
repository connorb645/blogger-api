//
//  File.swift
//  
//
//  Created by Connor Black on 08/10/2021.
//

import Foundation
import Vapor
import Fluent

struct BlogPostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let blogPostsRoute = routes.grouped("blog-posts")
        let bearerAuthProtected = blogPostsRoute.grouped(Token.authenticator())
        
        // Get blog post by id
        blogPostsRoute.get(":id", use: getBlogPost)
        blogPostsRoute.get(use: getAllBlogPosts)
        
        // Create
        bearerAuthProtected.post(use: createBlogPost)
        bearerAuthProtected.get("mine", use: getMyBlogPosts)
        
    }
    
    private func createBlogPost(req: Request) throws -> EventLoopFuture<BlogPost.Public> {
        let user = try req.auth.require(User.self)
        
        guard let userId = user.id else {
#warning("We are going to want a more specific user error here.")
            return req.eventLoop.future(error: UserError.alreadyExists)
        }
            
        #warning("Make blog post validatable and validate the body")
        
        // Parse the body to a blog post
        let blogPostCreation = try req.content.decode(BlogPost.Creation.self)
        
        let newBlogPost = try BlogPost.create(with: blogPostCreation, authorId: userId)
        
        return newBlogPost.save(on: req.db)
            .flatMapThrowing {
                return try newBlogPost.asPublic()
            }
    }
    
    private func getBlogPost(req: Request) throws -> EventLoopFuture<BlogPost.Public> {
        guard let idString = req.parameters.get("id") else {
            return req.eventLoop.future(error: Abort(.badRequest))
        }
        
        guard let id = UUID(idString) else {
            print(idString)
            return req.eventLoop.future(error: Abort(.internalServerError))
        }
                
        return BlogPost.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { unwrappedBlogPost in
                return try unwrappedBlogPost.asPublic()
            }
    }
    
    private func getAllBlogPosts(req: Request) throws -> EventLoopFuture<[BlogPost.Public]> {
        BlogPost.query(on: req.db)
            .all()
            .flatMapThrowing { blogPosts in
                return try blogPosts.map { try $0.asPublic() }
            }
    }
    
    private func getMyBlogPosts(req: Request) throws -> EventLoopFuture<[BlogPost.Public]> {
        
        // get the current user
        let user = try req.auth.require(User.self)
        
        guard let userId = user.id else {
            return req.eventLoop.future(error: Abort(.unauthorized))
        }
        
        // return all blog posts where the authorId == current user id
        return BlogPost.query(on: req.db)
            .filter(\.$author.$id == userId)
            .all()
            .flatMapThrowing { blogPosts in
                return try blogPosts.map { try $0.asPublic() }
            }
    }
}
