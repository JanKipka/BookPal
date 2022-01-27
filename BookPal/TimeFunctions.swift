//
//  TimeFunctions.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import Foundation

public func getTimeUnitFromTimeInterval(_ timeInterval: TimeInterval) -> TimeUnit {
    var minutenDouble = timeInterval / 60
    var minuten = floor(minutenDouble)
    let minutenFracture = minutenDouble - minuten
    
    let sekunden = Int(round(minutenFracture * 60))
    
    let stundenDouble = minuten / 60
    let stunden = floor(stundenDouble)
    let stundenFracture = stundenDouble - stunden
    
    minutenDouble = stundenFracture * 60
    minuten = round(minutenDouble)
    
    return TimeUnit(hours: Int(stunden), minutes: Int(minuten), seconds: Int(sekunden))
}

public func getMinutesFromTimeInterval(_ interval: TimeInterval) -> Double {
    return interval / 60
}
