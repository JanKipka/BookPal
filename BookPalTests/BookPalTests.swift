//
//  BookPalTests.swift
//  BookPalTests
//
//  Created by Jan Kipka on 27.01.22.
//

import XCTest
@testable import BookPal

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
