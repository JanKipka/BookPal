//
//  DateExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

extension TimeInterval {
    
    public var asDaysHoursMinutesString: String {
        let formatter: DateComponentsFormatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter.string(from: self)!
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
