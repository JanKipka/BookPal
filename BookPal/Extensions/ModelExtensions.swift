//
//  ModelExtensions.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation

protocol DynamicDateComponent {
    func passedTimeFromDateSinceStart(_ date: Date) -> TimeUnit?
}

extension ReadingActivity: DynamicDateComponent {
    
    var passedTimeUntilNow: TimeUnit {
        get {
            let interval = Date().timeIntervalSince(startedAt ?? Date())
            return getTimeUnitFromTimeInterval(interval)!
        }
    }
    
    func passedTimeFromDateSinceStart(_ date: Date) -> TimeUnit? {
        let interval = date.timeIntervalSince(startedAt ?? Date())
        return getTimeUnitFromTimeInterval(interval)
    }
    
    var timeSpentReading: TimeUnit {
        get {
            if let end = finishedAt {
                let interval = end.timeIntervalSince(startedAt!)
                return getTimeUnitFromTimeInterval(interval)!
            }
            
            return passedTimeUntilNow
        }
    }
}

extension ReadingCycle: DynamicDateComponent {
    
    func passedTimeFromDateSinceStart(_ date: Date) -> TimeUnit? {
        let interval = date.timeIntervalSince(startedAt ?? Date())
        return getTimeUnitFromTimeInterval(interval)
    }
    
    
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
        let inactiveAcs = acArray.filter({!$0.active})
        for ac in inactiveAcs {
            avg += ac.pagesPerMinute
        }
        return avg / Double(inactiveAcs.count)
    }
    
    var totalTimeSpentReading: TimeUnit? {
        let acArray = Array(self.readingActivities as! Set<ReadingActivity>)
        var sum: TimeInterval = TimeInterval()
        for ac in acArray {
            if !ac.active {
                sum += (ac.finishedAt?.timeIntervalSince(ac.startedAt!))!
            }
        }
        return getTimeUnitFromTimeInterval(sum)
    }
    
    var getActiveActivities: [ReadingActivity] {
        return Array(self.readingActivities as! Set<ReadingActivity>)
    }
    
    var hasActiveActivities: Bool {
        let acArray = getActiveActivities
        return !acArray.filter({$0.active}).isEmpty
    }
    
    var finishedStatus: FinishedStatus {
        get {
            return FinishedStatus(rawValue: self.finishedStatusValue)!
        }
        
        set {
            self.finishedStatusValue = newValue.rawValue
        }
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

extension Book {
    
    func filterAuthors(_ query: String) -> Bool {
        return Authors(self.authors!).names.contains(query)
    }
    
}
