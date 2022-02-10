//
//  DateExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

extension TimeInterval {
    
    var asDaysHoursMinutesString: String? {
        let formatter: DateComponentsFormatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: self)
    }
    
    var daysHoursMinutes: [Int] {
        let day = 86400.0;
        let hour = 3600.0;
        let minute = 60.0;

        let totalseconds = self

        let daysout = floor(totalseconds / day);
        let hoursout = floor((totalseconds - daysout * day)/hour);
        let minutesout = floor((totalseconds - daysout * day - hoursout * hour)/minute);
        return [Int(daysout), Int(hoursout), Int(minutesout)]
    }
}


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

extension Date {
    var asLocalizedStringHoursMinutes: String {
        Date.FormatStyle().locale(Locale.current).day(FormatStyle.Symbol.Day.twoDigits).month(FormatStyle.Symbol.Month.twoDigits).year().hour().minute().format(self)
    }
    
    var asLocalizedStringHoursMinutesSeconds: String {
        Date.FormatStyle().locale(Locale.current).day(FormatStyle.Symbol.Day.twoDigits).month(FormatStyle.Symbol.Month.twoDigits).year().hour().minute().second().format(self)
    }
}

extension Date {
    
    var zeroSeconds: Date? {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        return calendar.date(from: dateComponents)
    }
    
    var year: Int? {
        return Calendar.current.component(.year, from: self)
    }
    
}

extension TimeUnit {
    private var dateBaseString: String {
        var part = ""
        if let month = month, let dayOfMonth = dayOfMonth {
            let day = dayOfMonth < 10 ? "0\(dayOfMonth)" : String(dayOfMonth)
            let mon = month < 10 ? "0\(month)" : String(month)
            part = "\(day).\(mon)."
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

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
