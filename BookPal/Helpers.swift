//
//  Model.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import Foundation

public struct TimeUnit {
    public var hours: Int
    public var minutes: Int
    public var seconds: Int
    public var computedMinutes: Int {
        get {
            return hours * 60 + minutes + (seconds > 0 ? Int(round(60 / Double(seconds))) : 0)
        }
    }
}

public struct Authors {
    private var namesArray: [String]
    public var names: String {
        get {
            return namesArray.joined(separator: ", ")
        }
    }
    
    init(_ names: [String]) {
        self.namesArray = names
    }
}

enum BookPalError: Error {
    case runtimeError(String)
}
