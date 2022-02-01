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

extension ReadingCycle {
    
    var remainingTime: TimeUnit? {
        let pagesLeft = self.book!.numOfPages - self.currentPage
        let avgPages = self.avgPagesPerMinute
        if avgPages > 0.0 {
            let roundedTimeLeft = round(Double(pagesLeft) / avgPages)
            let asIntasSeconds = Int(roundedTimeLeft) * 60
            return getTimeUnitFromTimeInterval(TimeInterval(asIntasSeconds))
        }
        
        return nil
    }
    
    var avgPagesPerMinute: Double {
        let acArray = Array(self.readingActivities as! Set<ReadingActivity>)
        var avg = 0.0
        for ac in acArray {
            avg += ac.pagesPerMinute
        }
        return avg / Double(acArray.count)
    }
    
}

extension Double {
    
    var asDecimalString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        let formattedValue = formatter.string(from: NSNumber(value: self))!
        return formattedValue
    }
    
}
