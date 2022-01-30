//
//  ViewComponents.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation
import SwiftUI

struct ReadingCycleComponent: View {
    
    var readingCycle: ReadingCycle
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Start Date").font(.subheadline)
            Text(readingCycle.startedAt!.asTimeUnit(displaySeconds: false).asDateString)
            Text("\(readingCycle.book?.title ?? "")").font(.headline)
        }
        
    }
}

struct ReadingActivityComponent: View {
    
    var readingActivity: ReadingActivity
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Start Date").font(.subheadline)
            Text("\(readingActivity.startedAt!.asTimeUnit(displaySeconds: false).asDateString) | Time Passed: \(readingActivity.passedTime.asHoursAndMinutesString)")
            Text("\(readingActivity.readingCycle?.book?.title ?? "")").font(.headline)
        }
        
    }
}