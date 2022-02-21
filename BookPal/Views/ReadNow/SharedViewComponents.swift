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
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    @ObservedObject var readingCycle: ReadingCycle
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ImageComponent(thumbnail: readingCycle.book?.coverLinks?.thumbnail ?? "", width: 70, height: 75)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(readingCycle.book?.title ?? "")").font(.system(size: 20))
                        .fontWeight(.semibold)
                    Text(Authors((readingCycle.book?.authors) ?? []).names)
                    Spacer()
                    if readingCycle.active {
                        HStack {
                            Text("on-page-of \(Int(readingCycle.currentPage)) \(Int(readingCycle.book?.numOfPages ?? 0))")
                            Spacer()
                            Text(readingCycle.hasActiveActivities ? "Reading" : readingCycle.readingActivities?.count == 0 ? "" : LocalizedStringKey("done-in \(readingCycle.remainingTime?.asDaysHoursMinutesString ?? "??m")"))
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        .font(.callout)
                    }
                }
            }
        }
        .padding(.vertical, 8)
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
        }
        .cornerRadius(5)
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
                        Text("\(readingActivity.passedTimeFromDateSinceStart(context.date).asDaysHoursMinutesString )")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    Text("\(readingActivity.readingCycle?.book?.title ?? "")").font(.headline)
                }
            }
        }
        .padding(.vertical)
    }
}

struct BookNavigationComponent: View {
    
    @ObservedObject var book: Book
    var authors: Authors
    var font: Font?
    @State var presentAlert = false
    @State var hasActiveActivityAlert = false
    var hasSwipeActions: Bool
    
    init(book: Book, hasSwipeActions: Bool = true) {
        self.init(book: book, font: .headline, hasSwipeActions: hasSwipeActions)
    }
    
    init(book: Book, font: Font, hasSwipeActions: Bool = true) {
        self.book = book
        self.authors = Authors(book.authors!)
        self.font = font
        self.hasSwipeActions = hasSwipeActions
    }
    
    var body: some View {
        NavigationLink(destination: BookView(book: book)) {
            HStack {
                ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "")
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(book.title ?? "")").font(font)
                    Text("\(authors.names)")
                }
            }
        }
        .padding(.vertical, 3)
        .listRowBackground(Color.clear)
        .swipeActions(edge: .leading) {
            if hasSwipeActions {
                BookSwipeActions(book: book, presentAlert: $presentAlert, hasActiveActivityAlert: $hasActiveActivityAlert)
            } else {
                EmptyView()
            }
        }
        .alert("delete-book", isPresented: $presentAlert) {
            ConfirmAlert {
                BooksController().deleteBook(book)
            }
        }
        .alert(LocalizedStringKey("Active activity ongoing"), isPresented: $hasActiveActivityAlert, actions: {
            Button("OK") {}
        }, message: {
            Text("already-active")
        })
    }
    
}

struct ReadingActivityListComponent: View {
    
    @ObservedObject var ac: ReadingActivity
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TimelineView(.everyMinute) { context in
                    Text("\(ac.active ? ac.passedTimeFromDateSinceStart(context.date).asDaysHoursMinutesString : ac.timeSpentReading.asDaysHoursMinutesString )")
                }
                
                Spacer()
                Text(getPagesString(readingActivitiy:ac))
            }
            HStack {
                Text(ac.startedAt?.asLocalizedStringHoursMinutes ?? "")
                    .font(.caption)
                Spacer()
                Text(ac.finishedAt?.asLocalizedStringHoursMinutes ?? "")
                    .font(.caption)
            }
        }
        .listRowBackground(ac.active ? Color.orangeAccent2 : .white)
        .padding(.vertical)
    }
    
    func getPagesString(readingActivitiy: ReadingActivity) -> LocalizedStringKey {
        return readingActivitiy.active ? LocalizedStringKey("active") : LocalizedStringKey("\(Int(readingActivitiy.pagesRead)) pages")
    }
    
}

struct ConfirmAlert: View {
    
    var onCancel: (() -> Void)?
    var onConfirm: () -> Void
    
    
    @ViewBuilder
    var body: some View {
        Button(LocalizedStringKey("No"), role: .cancel) {
            if let onCancel = onCancel {
                onCancel()
            }
        }
        Button(LocalizedStringKey("Yes")) {
            onConfirm()
        }
    }
}

struct BookSwipeActions: View {

    var book: Book
    @Binding var presentAlert: Bool
    @Binding var hasActiveActivityAlert: Bool
    
    let readingController: ReadingController = ReadingController()

    @ViewBuilder
    var body: some View {
        Button {
            let active = readingController.hasActiveReadingActivities()
            if active {
                hasActiveActivityAlert.toggle()
                return
            }
            let cycle = readingController.createNewReadingCycle(book: book, startedOn: Date.now)
            let _ = readingController.createNewActivity(readingCycle: cycle, onPage: cycle.currentPage)
        } label: {
            Label("read-now", systemImage: "book.fill")
        }
        .tint(.blue)
        Button(role: .destructive) {
            presentAlert = true
        } label: {
            Image(systemName: "trash")
        }
    }
}

struct TappedBookButton: View {
    @State var tappedBook: Book?
    var book: Book
    
    var body: some View {
        Button {
            tappedBook = book
        } label: {
            BookNavigationComponent(book: book, hasSwipeActions: false)
        }
        .padding(.vertical)
        .foregroundColor(.primary)
        .sheet(item: $tappedBook) {  book in
            BookView(book: book, isSheet: true)
        }
    }
}

// PREVIEWS

struct ImageComponentPreviews: PreviewProvider {
    static var previews: some View {
        ImageComponent(thumbnail: "https://assets.thalia.media/img/artikel1/537d8abe0db2fc7bccb7a989a135a06553028624-00-00.jpeg", width: 100, height: 180)
    }
    
}

struct ReadingActivityListComponentPreviews: PreviewProvider {
    
    static var previews: some View {
        let ac = PreviewController().createActiveRunningReadingActivity()
        return ReadingActivityListComponent(ac: ac)
    }
}

struct BookComponentPreviews: PreviewProvider {
    static var previews: some View {
        let book = PreviewController().createNewBookForPreview()
        return List {
            BookNavigationComponent(book: book)
        }
        .listStyle(.grouped)
    }
}
