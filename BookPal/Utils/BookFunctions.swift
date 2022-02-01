//
//  BookFunctions.swift
//  BookPal
//
//  Created by Jan Kipka on 01.02.22.
//

import Foundation

func calculatePagesPerMinuteFromInterval(_ interval: TimeInterval, pagesRead: Int16) -> Double {
    let minutesInInterval = getMinutesFromTimeInterval(interval)
    return Double(pagesRead) / round(minutesInInterval)
}
