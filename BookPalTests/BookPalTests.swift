//
//  BookPalTests.swift
//  BookPalTests
//
//  Created by Jan Kipka on 27.01.22.
//

import XCTest
@testable import BookPal

class Book {
    var title: String
    var authors: Authors
    var isbn: String
    var cover: String?
    var numOfPages: Int
    var genre: Genre
    var readingCycles: [ReadingCycle]
    
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
    
    func addReadingCycle(_ cycle: ReadingCycle) {
        self.readingCycles.append(cycle)
    }
}

class Genre {
    var name: String
    var books: [Book]
    
    init(name: String) {
        self.name = name
        books = []
    }
    
    func addBook(_ book: Book) {
        self.books.append(book)
    }
}

class ReadingCycle {
    var startetAt: Date
    var finishedAt: Date
    var book: Book
    var readingActivities: [ReadingActivity]
    var notes: String?
    var remainingTime: TimeUnit {
        get {
            let remainingTime = Int(round(Double(self.calculateTotalPagesLeft()) / self.calculateAveragePagesPerMinute()))
            return getTimeUnitFromTimeInterval(TimeInterval(remainingTime * 60))
        }
    }
    
    var averagePagesPerMinute: Double {
        get {
            return calculateAveragePagesPerMinute()
        }
    }
    
    var totalPagesRead: Int {
        get {
            return self.book.numOfPages - calculateTotalPagesLeft()
        }
    }
    
    var totalTimeSpentReading: TimeUnit {
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

class ReadingActivity {
    var startetAt: Date
    var finishedAt: Date
    var amountOfPagesRead: Int
    var notes: String?
    var timeInterval: TimeInterval {
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

class BookPalTests: XCTestCase {
    
    func testNewReadingCycleScenario() {
        let genre = Genre(name: "Horror")
        let book = Book(title: "Test", authors: Authors(["Michael Test"]), isbn: "1234562731^", cover: "", numOfPages: 470, genre: genre)
        XCTAssertEqual(book.authors.names, "Michael Test")
        
        var startDate = Date()
        let timePassedReadingTheBook = 430800
        let endDate = startDate.addingTimeInterval(TimeInterval(timePassedReadingTheBook))
        let cycle = ReadingCycle(startedAt: startDate, finishedAt: endDate, book: book)
        
        let endDateFirstActivity = startDate.addingTimeInterval(TimeInterval(5400))
        var pagesLeft = book.numOfPages
        var amountOfPagesRead = 90
        pagesLeft = pagesLeft - amountOfPagesRead
        let readingActivity1 = ReadingActivity(startedAt: startDate, finishedAt: endDateFirstActivity, amountOfPagesRead: amountOfPagesRead)
        cycle.addReadingActivity(readingActivity1)
        XCTAssertEqual(cycle.totalPagesRead, 90)
        XCTAssertEqual(cycle.averagePagesPerMinute, 1)
        XCTAssertEqual(cycle.remainingTime.computedMinutes, 380)
        
        let pauseAfterFirstActivity = 237600
        startDate = endDateFirstActivity.addingTimeInterval(TimeInterval(pauseAfterFirstActivity))
        let endDateSecondActivty = startDate.addingTimeInterval(TimeInterval(7800))
        amountOfPagesRead = 260
        pagesLeft = pagesLeft - amountOfPagesRead
        let readingActivity2 = ReadingActivity(startedAt: startDate, finishedAt: endDateSecondActivty, amountOfPagesRead: amountOfPagesRead)
        cycle.addReadingActivity(readingActivity2)
        XCTAssertEqual(cycle.totalPagesRead, 350)
        XCTAssertEqual(cycle.averagePagesPerMinute, 1.5)
        XCTAssertEqual(cycle.remainingTime.computedMinutes, 80)
        
        let pauseAfterSecondActivity = 172800
        startDate = endDateSecondActivty.addingTimeInterval(TimeInterval(pauseAfterSecondActivity))
        let endDateThirdActivity = endDate
        let readingActivity3 = ReadingActivity(startedAt: startDate, finishedAt: endDateThirdActivity, amountOfPagesRead: pagesLeft)
        cycle.addReadingActivity(readingActivity3)
        XCTAssertEqual(cycle.totalPagesRead, 470)
        XCTAssertEqual(cycle.averagePagesPerMinute, 4/3)
        XCTAssertEqual(cycle.remainingTime.computedMinutes, 0)
        XCTAssertEqual(cycle.totalTimeSpentReading.computedMinutes, 340)
    }
    
}
