//
//  TimeModels.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
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

}
