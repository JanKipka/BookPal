//
//  PreviewController.swift
//  BookPal
//
//  Created by Jan Kipka on 03.02.22.
//

import Foundation
import CoreData

struct PreviewController {
    
    let dataController = DataController.preview
    
    func createNewBookForPreview() -> Book {
        let context = dataController.container.viewContext
        let book = Book(context: context)
        book.title = "Preview Book"
        book.id = UUID()
        let auth = Author(context: context)
        auth.lastName = "Testeroni"
        auth.firstName = "Michael"
        auth.id = UUID()
        book.addToAuthors(auth)
        let links = CoverLinks(context: context)
        links.thumbnail = "https://assets.thalia.media/img/artikel/537d8abe0db2fc7bccb7a989a135a06553028624-00-00.jpeg"
        book.coverLinks = links
        let genre = Genre(context: context)
        genre.name = "Fiction"
        book.genre = genre
        book.numOfPages = 320
        book.isbn = "97843256432"
        let readingCycle = ReadingCycle(context: context)
        readingCycle.book = book
        readingCycle.id = UUID()
        readingCycle.startedAt = Date().addingTimeInterval(-100_000_000)
        readingCycle.completedOn = Date().addingTimeInterval(-50_000_000)
        readingCycle.finishedStatus = .read
        readingCycle.currentPage = 320
        readingCycle.active = false
        
        let readingActivity = ReadingActivity(context: context)
        readingActivity.startedAt = readingCycle.startedAt
        readingActivity.readingCycle = readingCycle
        readingActivity.id = UUID()
        readingActivity.startedActivityOnPage = 0
        readingActivity.finishedActivityOnPage = 200
        readingActivity.pagesPerMinute = 0.6
        readingActivity.finishedAt = readingActivity.startedAt?.addingTimeInterval(100_000)
        
        let readingActivity2 = ReadingActivity(context: context)
        readingActivity2.startedAt = readingActivity.finishedAt?.addingTimeInterval(10_000_000)
        readingActivity2.readingCycle = readingCycle
        readingActivity2.id = UUID()
        readingActivity2.pagesPerMinute = 0.5
        readingActivity2.startedActivityOnPage = 200
        readingActivity2.finishedActivityOnPage = 320
        readingActivity2.finishedAt = readingActivity2.startedAt?.addingTimeInterval(90_000)
        return book
    }
    
    
    func createActiveRunningReadingActivity() -> ReadingActivity {
        let ac = ReadingActivity(context: dataController.container.viewContext)
        ac.startedAt = Date()
        ac.active = true
        ac.pagesRead = 0
        return ac
    }
    
}
