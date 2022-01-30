//
//  ModelExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

extension ReadingActivity {
    
    var passedTime: TimeUnit {
        get {
            let interval = Date().timeIntervalSince(startedAt ?? Date())
            return getTimeUnitFromTimeInterval(interval)
        }
    }
    
}
