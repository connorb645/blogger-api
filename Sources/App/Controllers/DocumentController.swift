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
    
//    func upload(req: Request) throws -> EventLoopFuture<Document.Public> {
//
//        try req.auth.require(User.self)
//
//        let fileName = try filename(with: req.headers)
//        let document = Document(documentName: fileName)
//        let path = document.path(for: req.application)
//
//        let statusPromise = req.eventLoop.makePromise(of: Document.Public.self)
//
//        req.body.drain { someResult -> EventLoopFuture<Void> in
//            let drainPromise = req.eventLoop.makePromise(of: Void.self)
//
//            switch someResult {
//            case .buffer(let buffer):
//                 _ = req.fileio.writeFile(buffer, at: path)
//                    .always { outcome in
//                        switch outcome {
//                        case .success(let yep):
//                            return drainPromise.succeed(yep)
//                        case .failure(let nope):
//                            return drainPromise.fail(nope)
//                        }
//                    }
//            case .error(let e):
//                try? FileManager.default.removeItem(atPath: path)
//                statusPromise.fail(e)
//                drainPromise.fail(e)
//            case .end:
//                _ = document.save(on: req.db)
//                    .flatMapThrowing { _ in
//                        try document.asPublic()
//                    }.always { result in
//                        switch result {
//                        case .success(let publicDocument):
//                            statusPromise.succeed(publicDocument)
//                        case .failure(let error):
//                            statusPromise.fail(error)
//                        }
//                    }
//                drainPromise.succeed(())
//            }
//
//            return drainPromise.futureResult
//        }
//        return statusPromise.futureResult
//    }
    
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
