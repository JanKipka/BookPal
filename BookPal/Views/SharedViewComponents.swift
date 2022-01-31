//
//  ViewComponents.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation
import SwiftUI
import UIKit

struct ReadingCycleComponent: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    @ObservedObject var readingCycle: ReadingCycle
    @State var showAlert = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ImageComponent(thumbnail: readingCycle.book?.coverLinks?.thumbnail ?? "")
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(readingCycle.startedAt!.asTimeUnit.asDateStringShort)")
                    Text("\(readingCycle.book?.title ?? "")").font(.headline)
                }
            }
        }
    }
}

struct ImageComponent: View {
    @State var thumbnail: String
    var body: some View {
        AsyncImage(url: URL(string: thumbnail)){ image in
            image.resizable()
        } placeholder: {
            Image("placeholder")
                .resizable()
                .frame(width: 60, height: 60, alignment: .center)
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 60, height: 60, alignment: .center)
    }
}

struct ReadingActivityComponent: View {
    
    @ObservedObject var readingActivity: ReadingActivity
    
    var body: some View {
        VStack (spacing: 10){
            HStack {
                ImageComponent(thumbnail: readingActivity.readingCycle?.book?.coverLinks?.thumbnail ?? "")
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(readingActivity.passedTimeUntilNow.asHoursMinutesString)")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text("\(readingActivity.readingCycle?.book?.title ?? "")").font(.headline)
                }
            }
        }
    }
}

struct BookComponent: View {
    
    @State var book: Book
    @State var authors: Authors
    
    init(book: Book) {
        self.book = book
        self.authors = Authors(book.authors!)
    }
    
    var body: some View {
        HStack {
            ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "")
            VStack(alignment: .leading, spacing: 5) {
                Text("\(book.title ?? "")").font(.headline)
                Text("\(authors.names)")
            }
        }
    }
    
}

struct ReadingActivityListComponent: View {
    
    var ac: ReadingActivity
    
    var body: some View {
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
    
    func getPagesString(readingActivitiy: ReadingActivity) -> String {
        return readingActivitiy.active ? "Active" : "\(readingActivitiy.pagesRead) pages"
    }
    
}
