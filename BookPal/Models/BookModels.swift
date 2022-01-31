//
//  BookModels.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation

public struct Authors {
    private var authorSet: Set<Author>
    
    public var names: String {
        get {
            let authors = Array(authorSet)
            var namesArray: [String] = []
            var name = ""
            for author in authors {
                name = "\(author.firstName ?? "") \(author.lastName ?? "")"
                namesArray.append(name)
            }
            return namesArray.joined(separator: ", ")
        }
    }
    
    init(_ authors: NSSet) {
        self.authorSet = authors as! Set<Author>
    }
}
