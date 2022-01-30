//
//  Model.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import Foundation

public struct TimeUnit {
    public var year: Int?
    public var month: Int?
    public var dayOfMonth: Int?
    
    public var hours: Int
    public var minutes: Int
    public var seconds: Int?
    
    public init(hours: Int, minutes: Int, seconds: Int?) {
        self.init(year: nil, month: nil, dayOfMonth: nil, hours: hours, minutes: minutes, seconds: seconds)
    }
    
    public init(year: Int?, month: Int?, dayOfMonth: Int?, hours: Int, minutes: Int, seconds: Int?) {
        self.year = year
        self.month = month
        self.dayOfMonth = dayOfMonth
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
    }
    
    public var computedMinutes: Int {
        get {
            return hours * 60 + minutes + (seconds ?? 0 > 0 ? Int(round(60 / Double(seconds ?? 0))) : 0)
        }
    }
    public var asString: String {
        var part = ""
        if let month = month, let dayOfMonth = dayOfMonth {
            part = "\(String(dayOfMonth)).\(String(month))."
        }
        
        if let year = year {
            part = "\(part)\(year)"
        }
        
        part = "\(part) \(hours):\(minutes)"
        
        if let seconds = seconds {
            part = "\(part):\(seconds)"
        } else {
            part = "\(part) Uhr"
        }
        
        return part
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

extension Date {
    func asTimeUnit(displaySeconds: Bool) -> TimeUnit {
        let date = self
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let dayOfMonth = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var seconds: Int?
        if displaySeconds {
            seconds = calendar.component(.second, from: date)
        }
        return TimeUnit(year: year, month: month, dayOfMonth: dayOfMonth, hours: hour, minutes: minutes, seconds: seconds)
    }
}
