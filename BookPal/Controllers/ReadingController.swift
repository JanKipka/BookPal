//
//  ReadingController.swift
//  BookPal
//
//  Created by Jan Kipka on 02.02.22.
//

import Foundation
import CoreData

struct ReadingController {
    
    let moc = DataController.shared.context
    
    let dataController = DataController.shared
    
    let booksController = BooksController()
    
}

extension ReadingController {
    // activities
    func createNewActivity(readingCycle: ReadingCycle, onPage: Int16 = 0) -> ReadingActivity {
        let readingActivity = ReadingActivity(context: moc)
        readingActivity.id = UUID()
        readingActivity.startedAt = Date().zeroSeconds
        readingActivity.readingCycle = readingCycle
        readingActivity.startedActivityOnPage = onPage
        readingActivity.active = true
        dataController.save()
        return readingActivity
    }
    
    func finishReadingActivity(readingActivity: ReadingActivity, onPage: Int16, notes: String) {
        let maxPages = readingActivity.readingCycle!.maxPages
        readingActivity.finishedActivityOnPage = onPage
        let onPageBefore = readingActivity.readingCycle?.currentPage ?? 0
        readingActivity.pagesRead = onPage - onPageBefore
        readingActivity.readingCycle?.currentPage = onPage
        readingActivity.finishedAt = Date().zeroSeconds
        let timePassedInterval = readingActivity.finishedAt?.timeIntervalSince(readingActivity.startedAt!)
        readingActivity.pagesPerMinute = calculatePagesPerMinuteFromInterval(timePassedInterval!, pagesRead: readingActivity.pagesRead)
        readingActivity.active = false
        readingActivity.notes = notes
        if onPage == maxPages {
            // book done
            let cycle = readingActivity.readingCycle!
            cycle.finishedStatus = .read
            cycle.active = false
            cycle.finishedAt = readingActivity.finishedAt
        }
        dataController.save()
    }
}

extension ReadingController {
    // cycles
    func createNewReadingCycle(book: Book, startedOn: Date) -> ReadingCycle {
        let readingCycle = ReadingCycle(context: moc)
        readingCycle.startedAt = startedOn
        readingCycle.active = true
        readingCycle.id = UUID()
        readingCycle.book = book
        readingCycle.maxPages = readingCycle.book!.numOfPages
        dataController.save()
        return readingCycle
    }
    
    func stopReading(cycle: ReadingCycle) {
        cycle.finishedStatus = .stopped
        let finishedDate = Date().zeroSeconds
        for ac in cycle.getActiveActivities {
            finishReadingActivity(readingActivity: ac, onPage: cycle.currentPage, notes: ac.notes ?? "")
        }
        cycle.active = false
        cycle.finishedAt = finishedDate
        dataController.save()
    }
}
