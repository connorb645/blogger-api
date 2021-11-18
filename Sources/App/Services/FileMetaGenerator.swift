//
//  File.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Foundation
import Vapor


struct FileMetaGenerator {
    private let req: Request
    var key: String = ""
    
    // ONLY USE 1 INSTANCE PER FILE
    init(req: Request) throws {
        self.req = req
        
        guard extensionIsSupported(using: req.headers) else {
            throw Abort(.unsupportedMediaType)
        }
        
        key = uniqueFileKey
    }
    
    private var uniqueFileKey: String {
        UUID().uuidString
    }
    
    private func extensionIsSupported(using headers: HTTPHeaders) -> Bool {
        headers.contentType == .plainText ||
        headers.contentType == .png ||
        headers.contentType == .jpeg ||
        headers.contentType == .svg
    }
}
