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
        formatter.zeroFormattingBehavior = .dropAll
        return formatter.string(from: self)!
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

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
}
