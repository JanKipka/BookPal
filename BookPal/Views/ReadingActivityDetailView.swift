//
//  ReadingActivityDetailView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct ReadingActivityDetailView: View {
    
    @ObservedObject var readingActivity: ReadingActivity
    @State var endDate: Date = Date()
    @State var timeSpentReadingString: String = ""
    var timePassed: String {
        readingActivity.passedTimeUntilNow.asHoursMinutesString
    }
    var timeSpentReading: String {
        readingActivity.timeSpentReading.asHoursMinutesString
    }
    @State var pagesRead: String = ""
    @State var showMessage: Bool = false
    @State var message: String = ""
    @State var notes: String = ""
    @State var pagesPerMinute: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    fileprivate func refreshDateRelatedValues(_ d: Date) {
        let interval = d.timeIntervalSince(readingActivity.startedAt!)
        self.timeSpentReadingString = getTimeUnitFromTimeInterval(interval)!.asHoursMinutesString
        readingActivity.pagesPerMinute = calculatePagesPerMinuteFromInterval(interval, pagesRead: readingActivity.pagesRead)
        self.pagesPerMinute = readingActivity.pagesPerMinute.asDecimalString
    }
    
    var body: some View {
        ZStack {
            Colors.linearGradient(topColor: Colors.mint, bottomColor: Colors.lighterMint)
                .ignoresSafeArea()
            VStack {
                Form {
                    BookComponent(book: readingActivity.readingCycle!.book!)
                        .padding()
                    Section("Start Date") {
                        Text(readingActivity.startedAt?.asLocalizedStringHoursMinutes ?? Date().formatted())
                    }
                    if !readingActivity.active {
                        Section("End Date") {
                            DatePicker("End Date", selection: $endDate)
                                .onChange(of: endDate) { d in
                                    refreshDateRelatedValues(d)
                                }
                        }
                    }
                    Section("Time spent reading") {
                        Text(timeSpentReadingString)
                    }
                    Section("Started on page") {
                        Text("\(readingActivity.startedActivityOnPage)")
                    }
                    Section("Finished on page") {
                        if !readingActivity.active {
                            Text("\(readingActivity.finishedActivityOnPage)")
                        } else {
                            TextField("What page are you on?", text: $pagesRead)
                        }
                    }
                    if !readingActivity.active {
                        Section("Pages per minute") {
                            Text(pagesPerMinute)
                        }
                    }
                    Section("Notes") {
                        TextEditor(text: $notes)
                    }
                }
                Spacer()
            }
            
        }.navigationTitle("Reading activity")
            .onAppear {
                self.endDate = readingActivity.finishedAt ?? Date()
                self.notes = readingActivity.notes ?? ""
                self.timeSpentReadingString = !readingActivity.active ? timeSpentReading : timePassed
                self.pagesPerMinute = readingActivity.pagesPerMinute.asDecimalString
            }
            .toolbar {
                ToolbarItem {
                    Button(readingActivity.active ? "Finish reading" : "Done") {
                        buttonAction()
                    }
                }
            }
            .navigationBarBackButtonHidden(!readingActivity.active)
            .alert(isPresented: $showMessage) {
                Alert(title: Text(message))
            }
    }
    
    fileprivate func buttonAction(){
        if !readingActivity.active {
            readingActivity.notes = notes
            readingActivity.finishedAt = endDate.zeroSeconds
            dataController.save()
            dismiss()
        } else {
            finishReadingActivity()
        }
    }
    
    fileprivate func fillReadingActivity(currentlyOnPage onPage: Int16) {
        readingActivity.finishedActivityOnPage = onPage
        let onPageBefore = readingActivity.readingCycle?.currentPage ?? 0
        readingActivity.pagesRead = onPage - onPageBefore
        readingActivity.readingCycle?.currentPage = onPage
        readingActivity.finishedAt = Date().zeroSeconds
        let timePassedInterval = readingActivity.finishedAt?.timeIntervalSince(readingActivity.startedAt!)
        readingActivity.pagesPerMinute = calculatePagesPerMinuteFromInterval(timePassedInterval!, pagesRead: readingActivity.pagesRead)
        readingActivity.active = false
        readingActivity.notes = notes
    }
    
    fileprivate func finishReadingActivity() {
        if pagesRead.isEmpty {
            showMessage = true
            message = "Please enter the page you're on."
            return
        }
        let onPage = Int16(pagesRead)!
        let maxPages = readingActivity.readingCycle!.maxPages
        if onPage > maxPages {
            showMessage = true
            message = "The page you're on can't be greater than the total page number (\(maxPages))."
            return
        }
        fillReadingActivity(currentlyOnPage: onPage)
        if onPage == maxPages {
            // book done
            let cycle = readingActivity.readingCycle!
            cycle.active = false
            cycle.finishedAt = readingActivity.finishedAt
        }
        dataController.save()
        dismiss()
    }
}
