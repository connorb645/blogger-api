//
//  File.swift
//  
//
//  Created by Connor Black on 09/11/2021.
//

import Foundation

protocol PublicRepresentable {
    associatedtype T
    
    var publicRepresentation: T { get throws }
}
