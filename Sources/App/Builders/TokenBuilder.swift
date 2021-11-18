//
//  TokenBuilder.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Vapor

enum TokenType: Int, Codable {
    case access, refresh
}

class TokenBuilder {
    var userId: UUID?
    var tokenType: TokenType?
    
    func setUserId(to id: UUID) -> TokenBuilder {
        self.userId = id
        return self
    }
    
    func setTokenType(to type: TokenType) -> TokenBuilder {
        self.tokenType = type
        return self
    }
    
    func build() throws -> Token {
        guard let userId = userId else {
            throw TokenBuilderError.missingUserId
        }
        
        guard let tokenType = tokenType else {
            throw TokenBuilderError.missingTokenType
        }
        
        let calendar = Calendar(identifier: .gregorian)
        
        let now = Date()
        
        guard let accessTokenExpiry = calendar.date(byAdding: .day, value: 7, to: now) else {
            throw TokenBuilderError.expiryDateCreation
        }
        
        guard let refreshTokenExpiry = calendar.date(byAdding: .month, value: 6, to: now) else {
            throw TokenBuilderError.expiryDateCreation
        }
        
        let token = [UInt8].random(count: 16).base64
        
        return .init(userId: userId,
                     tokenType: tokenType,
                     token: token,
                     expiresAt: tokenType == .access ? accessTokenExpiry : refreshTokenExpiry)

    }
}
