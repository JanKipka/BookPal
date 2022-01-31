//
//  ModelExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

extension ReadingActivity {
    
    var passedTimeUntilNow: TimeUnit {
        get {
            let interval = Date().timeIntervalSince(startedAt ?? Date())
            return getTimeUnitFromTimeInterval(interval)
        }
    }
    
    var timeSpentReading: TimeUnit {
        get {
            if let end = finishedAt {
                let interval = end.timeIntervalSince(startedAt!)
                return getTimeUnitFromTimeInterval(interval)
            }
            
            return passedTimeUntilNow
        }
    }
    
}
