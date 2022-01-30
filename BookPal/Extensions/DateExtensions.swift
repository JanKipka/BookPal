//
//  DateExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

extension Date {
    var asTimeUnit: TimeUnit {
        let date = self
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let dayOfMonth = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var seconds: Int = calendar.component(.second, from: date)
        seconds = calendar.component(.second, from: date)
        return TimeUnit(year: year, month: month, dayOfMonth: dayOfMonth, hours: hour, minutes: minutes, seconds: seconds)
    }
}

extension TimeUnit {
    private var dateBaseString: String {
        var part = ""
        if let month = month, let dayOfMonth = dayOfMonth {
            part = "\(String(dayOfMonth)).\(String(month))."
        }
        
        if let year = year {
            part = "\(part)\(year)"
        }
        
        let concat = minutes < 10 ? "0\(minutes)" : String(minutes)
        part = "\(part) \(hours):\(concat)"
        return part
    }
    public var asDateStringShort: String {
        "\(dateBaseString) Uhr"
    }
    public var asDateStringLong: String {
        var part = dateBaseString
        
        if let seconds = seconds {
            let concat = seconds < 10 ? "0\(seconds)" : String(seconds)
            part = "\(part):\(concat)"
        }
        
        return part
    }
    public var asHoursMinutesString: String {
        print(hours)
        print(minutes)
        var part = ""
        if hours > 0 {
            part = "\(hours)h "
        }
        let min = seconds ?? 0 > 30 ? minutes + 1 : minutes
        if minutes > 0||part.isEmpty {
            part = "\(part)\(min)m"
        }
        
        return part
    }
    public var asHoursMinutesSecondsString: String {
        return "\(asHoursMinutesString) \(seconds ?? 0)s"
    }
    public var computedMinutes: Int {
        get {
            return hours * 60 + minutes + (seconds ?? 0 > 0 ? Int(round(60 / Double(seconds ?? 0))) : 0)
        }
    }
}
