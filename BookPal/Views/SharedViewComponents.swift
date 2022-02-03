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
                ImageComponent(thumbnail: readingCycle.book?.coverLinks?.thumbnail ?? "", width: 70, height: 75)
                VStack(alignment: .leading, spacing: 5) {
                        TimelineView(.everyMinute) { context in
                            Text("Started \(context.date.timeIntervalSince(readingCycle.startedAt!).asDaysHoursMinutesString ?? "0m") ago")
                                .font(.callout)
                        }
                    Text("\(readingCycle.book?.title ?? "")").font(.headline)
                    if readingCycle.active {
                        HStack {
                            Text("p. \(readingCycle.currentPage) of \(readingCycle.book!.numOfPages)")
                            Spacer()
                            Text(readingCycle.hasActiveActivities ? "Reading" : readingCycle.readingActivities?.count == 0 ? "" : "Done in \(readingCycle.remainingTime?.asHoursMinutesString ?? "??m")")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        .font(.callout)
                    }
                }
            }
        }
    }
}

struct ImageComponent: View {
    var thumbnail: String
    var width: CGFloat = 60
    var height: CGFloat = 60
    
    var body: some View {
        AsyncImage(url: URL(string: thumbnail)){ image in
            image.resizable()
        } placeholder: {
            Image("placeholder")
                .resizable()
                .frame(width: width, height: height, alignment: .center)
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: height, alignment: .center)
    }
}

struct ReadingActivityComponent: View {
    
    @ObservedObject var readingActivity: ReadingActivity
    
    var body: some View {
        VStack (spacing: 10){
            HStack {
                ImageComponent(thumbnail: readingActivity.readingCycle?.book?.coverLinks?.thumbnail ?? "")
                VStack(alignment: .leading, spacing: 5) {
                    TimelineView(.everyMinute) { context in
                        Text("\(readingActivity.passedTimeFromDateSinceStart(context.date)?.asHoursMinutesString ?? "0m")")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    Text("\(readingActivity.readingCycle?.book?.title ?? "")").font(.headline)
                }
            }
        }
    }
}

struct BookComponent: View {
    
    @State var book: Book
    @State var authors: Authors
    var font: Font?
    
    init(book: Book) {
        self.init(book: book, font: .headline)
    }
    
    init(book: Book, font: Font) {
        self.book = book
        self.authors = Authors(book.authors!)
        self.font = font
    }
    
    var body: some View {
        HStack {
            ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "")
            VStack(alignment: .leading, spacing: 5) {
                Text("\(book.title ?? "")").font(font)
                Text("\(authors.names)")
            }
        }
    }
    
}

struct ReadingActivityListComponent: View {
    
    @ObservedObject var ac: ReadingActivity
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TimelineView(.periodic(from: ac.startedAt!, by: ac.active ? 30 : 0)) { context in
                    Text("\(ac.active ? ac.passedTimeFromDateSinceStart(context.date)?.asHoursMinutesString ?? "0m" : ac.timeSpentReading.asHoursMinutesString)")
                }
                
                Spacer()
                Text("\(getPagesString(readingActivitiy:ac))")
            }
            HStack {
                Text(ac.startedAt?.asLocalizedStringHoursMinutes ?? "")
                    .font(.caption)
                Spacer()
                Text(ac.finishedAt?.asLocalizedStringHoursMinutes ?? "")
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
