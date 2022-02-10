//
//  BookFunctions.swift
//  BookPal
//
//  Created by Jan Kipka on 01.02.22.
//

import Foundation

func calculatePagesPerMinuteFromInterval(_ interval: TimeInterval, pagesRead: Int16) -> Double {
    let minutesInInterval = getMinutesFromTimeInterval(interval)
    let rounded = round(minutesInInterval)
    if rounded == 0.0 {
        return 0.0
    }
    return Double(pagesRead) / rounded
}
