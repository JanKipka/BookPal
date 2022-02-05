//
//  ReadingCycleDetailView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct ReadingCycleDetailView: View {
    
    var readingCycle: ReadingCycle
    var activities: [ReadingActivity]
    @State var notes: String
    @State var avgPagesPerMinute = ""
    let dataController = DataController.shared
    
    init(readingCycle: ReadingCycle) {
        self.readingCycle = readingCycle
        let activitiesSet = readingCycle.readingActivities as! Set<ReadingActivity>
        self.activities = Array(activitiesSet).sorted {
            if let start = $0.startedAt, let start2 = $1.startedAt {
                return start < start2
            }
            
            return false
        }
        self.notes = readingCycle.notes ?? ""
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Colors.linearGradient(topColor: Colors.orange, bottomColor: Colors.lighterOrange)
                .ignoresSafeArea()
            VStack {
                
                Form {
                    BookComponent(book: readingCycle.book!)
                        .padding(.vertical)
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
                            Text("\(readingCycle.totalTimeSpentReadingInterval.asDaysHoursMinutesString ?? "0m")")
                        }
                    }
                    Section(LocalizedStringKey("Average pages per minute")) {
                        Text(avgPagesPerMinute)
                    }
                    Section(LocalizedStringKey("Notes")) {
                        TextEditor(text: $notes)
                    }
                    Section(LocalizedStringKey("Activities")) {
                        ForEach(activities) { ac in
                            NavigationLink(destination: ReadingActivityDetailView(readingActivity: ac)) {
                                ReadingActivityListComponent(ac: ac)
                            }
                        }
                    }
                }
            }
        }.navigationTitle(readingCycle.active ? LocalizedStringKey("You're reading...") : LocalizedStringKey("reading-log"))
            .onAppear {
                self.avgPagesPerMinute = readingCycle.avgPagesPerMinute.asDecimalString
            }
            .toolbar {
                ToolbarItem {
                    Button(LocalizedStringKey("Save")) {
                        readingCycle.notes = notes.trimmingCharacters(in: .whitespaces)
                        dataController.save()
                    }
                    .disabled(notes == readingCycle.notes || (readingCycle.notes == nil && notes.isEmpty))
                }
            }
    }

    
    func getPagesString(readingActivitiy: ReadingActivity) -> String {
        return readingActivitiy.active ? "Active" : "\(readingActivitiy.pagesRead) pages"
    }
    
}
