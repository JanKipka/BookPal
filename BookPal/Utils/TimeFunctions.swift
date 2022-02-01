//
//  TimeFunctions.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import Foundation

public func getTimeUnitFromTimeInterval(_ timeInterval: TimeInterval) -> TimeUnit? {
    if timeInterval == 0 {
        return nil
    }
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

public func calculateRemainingTimeForCycle(_ readingCycle: ReadingCycle) -> TimeUnit? {
    let pagesLeft = readingCycle.book!.numOfPages - readingCycle.currentPage
    let avgPages = readingCycle.avgPagesPerMinute
    if avgPages > 0.0 {
        let roundedTimeLeft = round(Double(pagesLeft) / avgPages)
        let asIntasSeconds = Int(roundedTimeLeft) * 60
        return getTimeUnitFromTimeInterval(TimeInterval(asIntasSeconds))
    }
    
    return nil
}

public func calculateAvgPagesPerMinuteForCycle(_ readingCycle: ReadingCycle) -> Double {
    let acArray = Array(readingCycle.readingActivities as! Set<ReadingActivity>)
    var avg = 0.0
    for ac in acArray {
        avg += ac.pagesPerMinute
    }
    return avg
}
