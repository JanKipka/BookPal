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
    
    init(readingCycle: ReadingCycle) {
        self.readingCycle = readingCycle
        let activitiesSet = readingCycle.readingActivities as! Set<ReadingActivity>
        self.activities = Array(activitiesSet).sorted {
            if let start = $0.startedAt, let start2 = $1.startedAt {
                return start < start2
            }
            
            return false
        }
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
                        Text(readingCycle.startedAt?.asTimeUnit.asDateStringShort ?? "")
                    }
                    Section("Current Page") {
                        Text("\(readingCycle.currentPage)")
                    }
                    Section("Total Pages") {
                        Text("\(readingCycle.book!.numOfPages)")
                    }
                    Section("Activities") {
                        ForEach(activities) { ac in
                            VStack(spacing: 10) {
                                HStack {
                                    Text("\(ac.timeSpentReading.asHoursMinutesString)")
                                    Spacer()
                                    Text("\(getPagesString(readingActivitiy:ac))")
                                }
                                HStack {
                                    Text(ac.startedAt?.asTimeUnit.asDateStringShort ?? "")
                                        .font(.caption)
                                    Spacer()
                                    Text(ac.finishedAt?.asTimeUnit.asDateStringShort ?? "")
                                        .font(.caption)
                                }
                            }
                            .listRowBackground(ac.active ? Colors.lighterOrange : .white)
                            .padding(.vertical)
                        }
                    }
                }
            }
        }.navigationBarTitle("Reading cycle")
    }
    
    func getPagesString(readingActivitiy: ReadingActivity) -> String {
        return readingActivitiy.active ? "Active" : "\(readingActivitiy.pagesRead) pages"
    }
    
}
