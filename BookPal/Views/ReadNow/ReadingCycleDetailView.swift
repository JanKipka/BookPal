//
//  ReadingCycleDetailView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct ReadingCycleDetailView: View {
    
    @ObservedObject var readingCycle: ReadingCycle
    @State var notes: String = ""
    @State var avgPagesPerMinute = ""
    @State var showActivityDetailSheet = false
    @State var tappedReadingActivity: ReadingActivity?
    let dataController = DataController.shared
    
    init(readingCycle: ReadingCycle) {
        self.readingCycle = readingCycle
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.orangeAccent, bottomColor: Color.orangeAccent2)
                .ignoresSafeArea()
            VStack {
                
                Form {
                    TappedBookButton(book: readingCycle.book!)
                    Section(LocalizedStringKey("start-date")) {
                        Text(readingCycle.startedAt?.asLocalizedStringHoursMinutes ?? "")
                    }
                    if !readingCycle.active {
                        Section(LocalizedStringKey("End Date")) {
                            Text(readingCycle.completedOn?.asLocalizedStringHoursMinutes ?? "")
                        }
                    }
                    Section(LocalizedStringKey(readingCycle.active ? "Pages read so far" : "Pages read")) {
                        Text(LocalizedStringKey("\(Int(readingCycle.currentPage)) of \(Int(readingCycle.book!.numOfPages))"))
                    }
                    Section(LocalizedStringKey("Time spent reading")) {
                        TimelineView(.everyMinute) { _ in
                            Text("\(readingCycle.totalTimeSpentReadingInterval.asDaysHoursMinutesString )")
                        }
                    }
                    Section(LocalizedStringKey("Average pages per minute")) {
                        Text(readingCycle.avgPagesPerMinute.asDecimalString)
                    }
                    Section(LocalizedStringKey("Notes")) {
                        TextEditor(text: $notes)
                    }
                    Section(LocalizedStringKey("Activities")) {
                        ForEach(readingCycle.getActivities.sorted(by: {$0.startedAt! < $1.startedAt!}) ) { ac in
                            Button {
                                tappedReadingActivity = ac
                                showActivityDetailSheet.toggle()
                            } label: {
                                ReadingActivityListComponent(ac: ac)
                            }
                            .foregroundColor(.primary)
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    if readingCycle.readingActivities?.count == 1 {
                                        readingCycle.currentPage = 0
                                    } else if !ac.active {
                                        readingCycle.currentPage = readingCycle.currentPage - ac.pagesRead
                                    }
                                    ReadingController().delete(object: ac)
                                } label: {
                                    Image(systemName: "trash")
                                }
                            }
                        }
                    }
                }
            }
        }.navigationTitle(readingCycle.active ? LocalizedStringKey("You're reading...") : LocalizedStringKey("reading-log"))
            .onAppear {
                self.notes = readingCycle.notes ?? ""
            }
            .sheet(item: $tappedReadingActivity) { ac in
                ReadingActivityDetailView(readingActivity: ac)
            }
            .toolbar {
                ToolbarItem {
                    Button(LocalizedStringKey("Save")) {
                        readingCycle.notes = notes.trimmingCharacters(in: .whitespaces)
                    }
                    .disabled(notes == readingCycle.notes || (readingCycle.notes == nil && notes.isEmpty))
                }
            }
    }
    
    
    func getPagesString(readingActivitiy: ReadingActivity) -> String {
        return readingActivitiy.active ? "Active" : "\(readingActivitiy.pagesRead) pages"
    }
    
}
