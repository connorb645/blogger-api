//
//  Document.swift
//  
//
//  Created by Connor Black on 23/10/2021.
//

import Foundation
import Fluent
import Vapor

final class Document: Model, Content {
    
    struct Public: Content {
        let id: UUID
        let documentName: String
    }
    
    static let schema = Tables.documents.rawValue
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: Fields.documentName.rawValue)
    var documentName: String
    
    init(id: UUID? = nil, documentName: String) {
        self.id = id
        self.documentName = documentName
    }
    
    init() {}
}


extension Document {
    enum Fields: FieldKey {
        case documentName = "document_name"
    }
}

extension Document {
    func path(for app: Application) -> String {
        "\(app.directory.workingDirectory)uploads/\(documentName)"
    }
}

extension Document {
    func asPublic() throws -> Document.Public {
        Document.Public(id: try requireID(),
                    documentName: documentName)
    }
}
