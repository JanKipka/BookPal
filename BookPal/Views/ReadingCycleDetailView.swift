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
    var activities: [ReadingActivity]
    @State var notes: String
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
            Colors.orange
                .ignoresSafeArea()
            VStack {
                
                Form {
                    BookComponent(book: readingCycle.book!)
                        .padding(.vertical)
                    Section("Start Date") {
                        Text(readingCycle.startedAt?.asLocalizedStringHoursMinutes ?? "")
                    }
                    Section("Pages read so far") {
                        Text("\(readingCycle.currentPage) of \(readingCycle.book!.numOfPages)")
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
        }.navigationTitle("Reading cycle")
            .onDisappear {
                if notes == readingCycle.notes {
                    return
                }
                readingCycle.notes = notes
                dataController.save()
            }
    }

    
    func getPagesString(readingActivitiy: ReadingActivity) -> String {
        return readingActivitiy.active ? "Active" : "\(readingActivitiy.pagesRead) pages"
    }
    
}
