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
    var numOfActiveActivities: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Start Date").font(.subheadline)
            Text(readingCycle.startedAt!.asTimeUnit(displaySeconds: false).asString)
            Text("\(readingCycle.book?.title ?? "")").font(.headline)
            Text("Active reading activities: \(numOfActiveActivities ?? 0)")
        }
        
    }
}
