//
//  ProfileImageGenerator.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Vapor

struct DocumentService {
    let req: Request
    
    init(req: Request) {
        self.req = req
    }
    
    func delete(withFileKey key: String) async throws {
        try await req.fs.delete(key: key).get()
    }
    
    func resolvePublicUrl(fromFileKey key: String) -> String {
        return req.fs.resolve(key: key)
    }
    
    func upload(data: Data?, withFileKey key: String) async throws -> String {
        guard let data = data else {
            throw Abort(.noContent)
        }
        
        _ = try await req.fs.upload(key: key, data: data).get()
        
        return key
    }
    
    func upload(byteBuffer: ByteBuffer?, withFileKey key: String) async throws -> String {
        guard let byteBuffer = byteBuffer else {
            throw Abort(.noContent)
        }
        
        let data = Data(buffer: byteBuffer)
        
        return try await upload(data: data, withFileKey: key)
    }
    
}
