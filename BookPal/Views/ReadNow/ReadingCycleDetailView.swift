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
                    Section("Start Date") {
                        Text(readingCycle.startedAt?.asLocalizedStringHoursMinutes ?? "")
                    }
                    if !readingCycle.active {
                        Section("End Date") {
                            Text(readingCycle.completedOn?.asLocalizedStringHoursMinutes ?? "")
                        }
                    }
                    Section(readingCycle.active ? "Pages read so far" : "Pages read") {
                        Text("\(readingCycle.currentPage) of \(readingCycle.book!.numOfPages)")
                    }
                    Section("Time spent reading") {
                        Text("\(readingCycle.totalTimeSpentReading?.asHoursMinutesString ?? "0m")")
                    }
                    Section("Average pages per minute") {
                        Text(avgPagesPerMinute)
                    }
                    Section("Notes") {
                        TextEditor(text: $notes)
                    }
                    Section("Activities") {
                        ForEach(activities) { ac in
                            NavigationLink(destination: ReadingActivityDetailView(readingActivity: ac)) {
                                ReadingActivityListComponent(ac: ac)
                            }
                        }
                    }
                }
            }
        }.navigationTitle("You're reading...")
            .onAppear {
                self.avgPagesPerMinute = readingCycle.avgPagesPerMinute.asDecimalString
            }
            .toolbar {
                ToolbarItem {
                    Button("Save") {
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
