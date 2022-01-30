//
//  DateExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

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

extension TimeUnit {
    public var asDateString: String {
        var part = ""
        if let month = month, let dayOfMonth = dayOfMonth {
            part = "\(String(dayOfMonth)).\(String(month))."
        }
        
        if let year = year {
            part = "\(part)\(year)"
        }
        
        let concat = minutes < 10 ? "0\(minutes)" : String(minutes)
        part = "\(part) \(hours):\(concat)"
        
        if let seconds = seconds {
            let concat = seconds < 10 ? "0\(seconds)" : String(seconds)
            part = "\(part):\(concat)"
        } else {
            part = "\(part) Uhr"
        }
        
        return part
    }
    public var asHoursAndMinutesString: String {
        var part = ""
        if hours > 0 {
            part = "\(hours)h "
        }
        if minutes > 0||part.isEmpty {
            part = "\(part)\(minutes)m"
        }
        return part
    }
    public var computedMinutes: Int {
        get {
            return hours * 60 + minutes + (seconds ?? 0 > 0 ? Int(round(60 / Double(seconds ?? 0))) : 0)
        }
    }
}
