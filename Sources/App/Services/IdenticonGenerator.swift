//
//  File.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Foundation
import Vapor

struct IdenticonGenerator {
    private let req: Request
    
    private let baseUrl = "https://identicon-api.herokuapp.com/"
    private let size = 100
    
    init(req: Request) {
        self.req = req
    }
    
    func generate(for string: String, at size: Int = 100) async throws -> Data {
        let client = req.client
        
        let uri = URI(string: "\(baseUrl)\(string)/\(size)?format=png")
        let response = try await client.get(uri)
        
        guard let buffer = response.body else {
            throw Abort(.noContent)
        }
        
        return Data(buffer: buffer)
    }
}
