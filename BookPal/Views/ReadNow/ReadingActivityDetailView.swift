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
    var refreshDate: Date?
    var timePassed: String {
        readingActivity.passedTimeFromDateSinceStart(refreshDate ?? .now).asDaysHoursMinutesString
    }
    var timeSpentReading: String {
        readingActivity.timeSpentReading.asDaysHoursMinutesString
    }
    @State var pagesRead: String = ""
    @State var showMessage: Bool = false
    @State var message: LocalizedStringKey = ""
    @State var notes: String = ""
    @State var pagesPerMinute: String = ""
    
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    let readingController = ReadingController()
    
    fileprivate func refreshDateRelatedValues(_ d: Date) {
        let interval = d.timeIntervalSince(readingActivity.startedAt!)
        self.timeSpentReadingString = interval.asDaysHoursMinutesString
        readingActivity.pagesPerMinute = calculatePagesPerMinuteFromInterval(interval, pagesRead: readingActivity.pagesRead)
        self.pagesPerMinute = readingActivity.pagesPerMinute.asDecimalString
    }
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.mintAccent, bottomColor: Color.mintAccent2)
                .ignoresSafeArea()
            VStack {
                Form {
                    BookComponent(book: readingActivity.readingCycle!.book!)
                        .padding()
                    if readingActivity.active {
                        Section(LocalizedStringKey("Started on page")) {
                            Text("\(readingActivity.startedActivityOnPage)")
                        }
                        Section(LocalizedStringKey("Finished on page")) {
                            if !readingActivity.active {
                                Text("\(readingActivity.finishedActivityOnPage)")
                            } else {
                                HStack {
                                    TextField("What page are you on?", text: $pagesRead)
                                    Button("I'm finished") {
                                        pagesRead = String(readingActivity.readingCycle?.book?.numOfPages ?? 0)
                                    }
                                }
                            }
                        }
                        Section(LocalizedStringKey("start-date")) {
                            Text(readingActivity.startedAt?.asLocalizedStringHoursMinutes ?? Date().formatted())
                        }
                        Section(LocalizedStringKey("Time spent reading")) {
                            TimelineView(.everyMinute) { context in
                                Text("\(context.date.timeIntervalSince(readingActivity.startedAt!).asDaysHoursMinutesString )")
                            }
                        }
                    } else {
                        Section(LocalizedStringKey("start-date")) {
                            Text(readingActivity.startedAt?.asLocalizedStringHoursMinutes ?? Date().formatted())
                        }
                        Section(LocalizedStringKey("End Date")) {
                            DatePicker(LocalizedStringKey("End Date"), selection: $endDate)
                                .onChange(of: endDate) { d in
                                    refreshDateRelatedValues(d)
                                }
                        }
                        Section(LocalizedStringKey("Time spent reading")) {
                            Text(timeSpentReadingString)
                        }
                        Section(LocalizedStringKey("Pages read")) {
                            Text("\(readingActivity.pagesRead)")
                        }
                        Section(LocalizedStringKey("Pages per minute")) {
                            Text(pagesPerMinute)
                        }
                    }
                    Section(LocalizedStringKey("Notes")) {
                        TextEditor(text: $notes)
                    }
                    
                    Button(readingActivity.active ? LocalizedStringKey("Finish reading") : LocalizedStringKey("Done")) {
                        buttonAction()
                    }
                    .listRowBackground(Color.blue)
                    .foregroundColor(.white)
                }
                Spacer()
            }
            
        }
        .onAppear {
            self.endDate = readingActivity.finishedAt ?? Date()
            self.notes = readingActivity.notes ?? ""
            self.timeSpentReadingString = !readingActivity.active ? timeSpentReading : timePassed
            self.pagesPerMinute = readingActivity.pagesPerMinute.asDecimalString
        }
        .alert(isPresented: $showMessage) {
            Alert(title: Text(message))
        }
    }
    
    fileprivate func buttonAction(){
        if !readingActivity.active {
            readingActivity.notes = notes
            readingActivity.finishedAt = endDate.zeroSeconds
            dismiss()
            dataController.save()
        } else {
            finishReadingActivity()
        }
    }
    
    fileprivate func finishReadingActivity() {
        if pagesRead.isEmpty {
            showMessage = true
            message = LocalizedStringKey("missing-page")
            return
        }
        let onPage = Int16(pagesRead)!
        let maxPages = readingActivity.readingCycle!.maxPages
        if onPage > maxPages {
            showMessage = true
            message = LocalizedStringKey("page-greater-than-total \(Int(maxPages))")
            return
        }
        readingController.finishReadingActivity(readingActivity: readingActivity, onPage: onPage, notes: notes)
        dismiss()
    }
}
