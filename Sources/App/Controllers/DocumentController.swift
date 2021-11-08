//
//  DocumentController.swift
//  
//
//  Created by Connor Black on 23/10/2021.
//

import Foundation
import Vapor

struct DocumentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let bearerAuthProtected = documentRoute.grouped(Token.authenticator())
        bearerAuthProtected.on(.POST, body: .collect(maxSize: "1mb"), use: upload)
    }
    
    func upload(req: Request) async throws -> String {
        let oByteBuffer = try await req.body.collect().get()
        
        guard let byteBuffer = oByteBuffer else {
            throw Abort(.noContent, "No data found")
        }
        
        let data = Data(buffer: byteBuffer)
                 
        let documentName = try filename(with: req.headers)
        let document = Document(documentName: documentName)
        let path = document.path(for: req.application)
                
        return try await req.fs.upload(key: path, data: data).get()
    }
    
    func filename(with headers: HTTPHeaders) throws -> String {
        let fileExt = try fileExtension(for: headers)
        return "\(UUID().uuidString).\(fileExt)"
    }
    
    func fileExtension(for headers: HTTPHeaders) throws -> String {
        
        guard let contentType = headers.contentType else {
            throw Abort(.badRequest, "Missing content type")
        }
        
        switch contentType {
        case .plainText:
             return "txt"
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        default:
            throw Abort(.unsupportedMediaType, "Unsupported content type \(contentType)")
        }
        
    }
}
