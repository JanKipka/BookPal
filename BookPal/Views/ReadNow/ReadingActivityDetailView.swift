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
        readingActivity.passedTimeFromDateSinceStart(refreshDate ?? .now)?.asHoursMinutesString ?? "0m"
    }
    var timeSpentReading: String {
        readingActivity.timeSpentReading.asHoursMinutesString
    }
    @State var pagesRead: String = ""
    @State var showMessage: Bool = false
    @State var message: LocalizedStringKey = ""
    @State var notes: String = ""
    @State var pagesPerMinute: String = ""
    var showButton = false
    
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    let readingController = ReadingController()
    
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
                    Section(LocalizedStringKey("start-date")) {
                        Text(readingActivity.startedAt?.asLocalizedStringHoursMinutes ?? Date().formatted())
                    }
                    if !readingActivity.active {
                        Section(LocalizedStringKey("End Date")) {
                            DatePicker(LocalizedStringKey("End Date"), selection: $endDate)
                                .onChange(of: endDate) { d in
                                    refreshDateRelatedValues(d)
                                }
                        }
                    }
                    Section(LocalizedStringKey("Time spent reading")) {
                        if readingActivity.active {
                            TimelineView(.everyMinute) { context in
                                Text("\(getTimeUnitFromTimeInterval(context.date.timeIntervalSince(readingActivity.startedAt!))?.asHoursMinutesString ?? "0m")")
                            }
                        } else {
                            Text(timeSpentReadingString)
                        }
                        
                    }
                    Section(LocalizedStringKey("Started on page")) {
                        Text("\(readingActivity.startedActivityOnPage)")
                    }
                    Section(LocalizedStringKey("Finished on page")) {
                        if !readingActivity.active {
                            Text("\(readingActivity.finishedActivityOnPage)")
                        } else {
                            TextField("What page are you on?", text: $pagesRead)
                        }
                    }
                    if !readingActivity.active {
                        Section(LocalizedStringKey("Pages per minute")) {
                            Text(pagesPerMinute)
                        }
                    }
                    Section(LocalizedStringKey("Notes")) {
                        TextEditor(text: $notes)
                    }
                    if showButton {
                        Button(LocalizedStringKey("Finish reading")) {
                            buttonAction()
                        }
                        .listRowBackground(Color.blue)
                        .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            
        }.navigationTitle(LocalizedStringKey("Reading activity"))
            .onAppear {
                self.endDate = readingActivity.finishedAt ?? Date()
                self.notes = readingActivity.notes ?? ""
                self.timeSpentReadingString = !readingActivity.active ? timeSpentReading : timePassed
                self.pagesPerMinute = readingActivity.pagesPerMinute.asDecimalString
            }
            .toolbar {
                ToolbarItem {
                    Button(readingActivity.active ? LocalizedStringKey("Finish reading") : LocalizedStringKey("Done")) {
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
