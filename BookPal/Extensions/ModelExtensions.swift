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
        if inactiveAcs.isEmpty {
            return 0.0
        }
        for ac in inactiveAcs {
            avg += ac.pagesPerMinute
        }
        return avg / Double(inactiveAcs.count)
    }
    
    var totalTimeSpentReadingInterval: TimeInterval {
        let acArray = Array(self.readingActivities as! Set<ReadingActivity>)
        var sum: TimeInterval = TimeInterval()
        for ac in acArray {
            if !ac.active {
                sum += (ac.finishedAt?.timeIntervalSince(ac.startedAt!))!
            } else {
                sum += Date.now.timeIntervalSince(ac.startedAt!)
            }
        }
        return sum
    }
    
    var totalTimeSpentReading: TimeUnit? {
        return getTimeUnitFromTimeInterval(totalTimeSpentReadingInterval)
    }
    
    var getActivities: [ReadingActivity] {
        return Array(self.readingActivities as! Set<ReadingActivity>)
    }
    
    var hasActiveActivities: Bool {
        let acArray = getActivities
        return !acArray.filter({$0.active}).isEmpty
    }
    
    var lastUpdated: Date {
        let acArray = getActivities
        if (acArray.isEmpty) {
            return .distantPast
        }
        if let active = acArray.filter({$0.active}).first {
            return active.startedAt!
        }
        return acArray.sorted(by: {$0.finishedAt ?? Date() > $1.finishedAt ?? Date()}).first?.finishedAt ?? .distantPast
    }
    
    var finishedStatus: FinishedStatus? {
        get {
            return FinishedStatus(rawValue: self.finishedStatusValue) ?? nil
        }
        
        set {
            self.finishedStatusValue = newValue!.rawValue
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
    
    var isRead: Bool {
        return readingCyclesAsArray.contains(where: {$0.finishedStatus == .read})
    }
    
    var lastUpdated: Date {
        return readingCyclesAsArray.map({$0.lastUpdated}).sorted(by: {$0 > $1}).first ?? Date.distantPast
    }
    
    func filterAuthors(_ query: String) -> Bool {
        return Authors(self.authors!).names.contains(query)
    }
    
    var readingCyclesAsArray: [ReadingCycle] {
        return Array(self.readingCycles as? Set<ReadingCycle> ?? [])
    }
    
    var averageTotalTimeSpentReading: TimeInterval {
        if readingCyclesAsArray.isEmpty {
            return 0.0
        }
        return totalTimeSpentReading / Double(readingCyclesAsArray.count)
    }
    
    var totalTimeSpentReading: TimeInterval {
        if readingCyclesAsArray.isEmpty {
            return 0.0
        }
        var res = TimeInterval()
        for cycle in readingCyclesAsArray {
            let interval = cycle.totalTimeSpentReadingInterval
            res += interval
        }
        return res
    }
    
}
