//
//  Model.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import Foundation

public struct TimeUnit {
    public var hours: Int
    public var minutes: Int
    public var seconds: Int
    public var computedMinutes: Int {
        get {
            return hours * 60 + minutes + (seconds > 0 ? Int(round(60 / Double(seconds))) : 0)
        }
    }
}

public struct Authors {
    private var namesArray: [String]
    public var names: String {
        get {
            return namesArray.joined(separator: ", ")
        }
    }
    
    init(_ names: [String]) {
        self.namesArray = names
    }
    
    
}

public class Book {
    public var title: String
    public var authors: Authors
    public var isbn: String
    public var cover: String?
    public var numOfPages: Int
    public var genre: Genre
    public var readingCycles: [ReadingCycle]
    
    init(title: String, authors: Authors, isbn: String, cover: String?, numOfPages: Int, genre: Genre) {
        self.title = title
        self.authors = authors
        self.isbn = isbn
        self.cover = cover
        self.numOfPages = numOfPages
        self.genre = genre
        self.readingCycles = []
        genre.addBook(self)
    }
    
    public func addReadingCycle(_ cycle: ReadingCycle) {
        self.readingCycles.append(cycle)
    }
}

public class Genre {
    public var name: String
    public var books: [Book]
    
    init(name: String) {
        self.name = name
        books = []
    }
    
    public func addBook(_ book: Book) {
        self.books.append(book)
    }
}

public class ReadingCycle {
    public var startetAt: Date
    public var finishedAt: Date
    public var book: Book
    public var readingActivities: [ReadingActivity]
    public var notes: String?
    public var remainingTime: TimeUnit {
        get {
            let remainingTime = Int(round(Double(self.calculateTotalPagesLeft()) / self.calculateAveragePagesPerMinute()))
            return getTimeUnitFromTimeInterval(TimeInterval(remainingTime * 60))
        }
    }
    
    public var averagePagesPerMinute: Double {
        get {
            return calculateAveragePagesPerMinute()
        }
    }
    
    public var totalPagesRead: Int {
        get {
            return self.book.numOfPages - calculateTotalPagesLeft()
        }
    }
    
    public var totalTimeSpentReading: TimeUnit {
        get {
            var totalTime = TimeInterval()
            for activity in readingActivities {
                totalTime = totalTime + activity.timeInterval
            }
            return getTimeUnitFromTimeInterval(totalTime)
        }
    }
    
    init(startedAt: Date, finishedAt: Date, book: Book) {
        self.startetAt = startedAt
        self.finishedAt = finishedAt
        self.book = book
        self.readingActivities = []
    }
    
    private func calculateAveragePagesPerMinute() -> Double {
        var avgPagesPerMinute = 0.0
        var amountOfPagesRead = 0
        for activity in readingActivities {
            amountOfPagesRead = amountOfPagesRead + activity.amountOfPagesRead
            let interval = activity.timeInterval
            let minutesPassed = getMinutesFromTimeInterval(interval)
            let pagesPerMinute = Double(activity.amountOfPagesRead) / minutesPassed
            avgPagesPerMinute = avgPagesPerMinute + pagesPerMinute
        }
        return avgPagesPerMinute / Double(readingActivities.count)
    }
    
    private func calculateTotalPagesLeft() -> Int {
        let totalPages = book.numOfPages
        var amountOfPagesRead = 0
        for activity in readingActivities {
            amountOfPagesRead = amountOfPagesRead + activity.amountOfPagesRead
        }
        return totalPages - amountOfPagesRead
    }
    
    func addReadingActivity(_ readingActivity: ReadingActivity) {
        self.readingActivities.append(readingActivity)
    }
    
}

public class ReadingActivity {
    public var startetAt: Date
    public var finishedAt: Date
    public var amountOfPagesRead: Int
    public var notes: String?
    public var timeInterval: TimeInterval {
        get {
            finishedAt.timeIntervalSince(startetAt)
        }
    }
    
    init(startedAt: Date, finishedAt: Date, amountOfPagesRead: Int, notes: String?) {
        self.startetAt = startedAt
        self.finishedAt = finishedAt
        self.amountOfPagesRead = amountOfPagesRead
        self.notes = notes
    }
    
    convenience init(startedAt: Date, finishedAt: Date, amountOfPagesRead: Int) {
        self.init(startedAt: startedAt, finishedAt: finishedAt, amountOfPagesRead: amountOfPagesRead, notes: nil)
    }
    
}
