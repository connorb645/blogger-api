//
//  DocumentController.swift
//  
//
//  Created by Connor Black on 23/10/2021.
//

import Foundation
import Vapor

struct FileController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let documentRoute = routes.grouped("files")
        
        documentRoute.get(":key", use: getPublicUrl)
        documentRoute.delete(":key", use: delete)
        
        let bearerAuthProtected = documentRoute.grouped(Token.authenticator())
        bearerAuthProtected.on(.POST, body: .collect(maxSize: "1mb"), use: upload)
    }
    
    // This will return the key to the image
    func upload(req: Request) async throws -> String {
        try req.auth.require(Token.self)
        
        let fileMetaGenerator = try FileMetaGenerator(req: req)
        let documentService = DocumentService(req: req)
        
        let fileKey = fileMetaGenerator.key
        let buffer = try await req.body.collect().get()
                        
        return try await documentService.upload(byteBuffer: buffer, withFileKey: fileKey)
    }
    
    // This will return the public url for a key
    func getPublicUrl(req: Request) throws -> String {
        let documentService = DocumentService(req: req)
        guard let documentKey = req.parameters.get("key") else {
            throw Abort(.badRequest)
        }
        
        return documentService.resolvePublicUrl(fromFileKey: documentKey)
    }
    
    func delete(req: Request) async throws -> String {
        let documentService = DocumentService(req: req)
        guard let documentKey = req.parameters.get("key") else {
            throw Abort(.badRequest)
        }
        
        try await documentService.delete(withFileKey: documentKey)
        
        return "\(documentKey) is now removed."
    }
    
}
