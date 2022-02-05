//
//  LibraryView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct LibraryView: View {
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "readingActivities.@count > 0")) var books: FetchedResults<ReadingCycle>
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "finishedStatusValue == 1")) var booksPutAway: FetchedResults<ReadingCycle>
    
    @FetchRequest(sortDescriptors: []) var allBooks: FetchedResults<Book>
    
    @State var pairs: [[Book]] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                    .ignoresSafeArea()
                List {
                    NavigationLink(destination: AllBooksView(navigationTitle: "Books")) {
                        LibrarySectionComponent(title: "Books", systemImage: "books.vertical")
                    }
                    .listRowBackground(Color.clear)
                    NavigationLink(destination: AuthorView()) {
                        LibrarySectionComponent(title: "Authors", systemImage: "person.2")
                    }
                    .listRowBackground(Color.clear)
                    NavigationLink(destination: GenreView()) {
                        LibrarySectionComponent(title: "Genres", systemImage: "list.bullet")
                    }
                    .listRowBackground(Color.clear)
                    NavigationLink(destination: AllBooksView(allBooks: books.filter({$0.finishedStatus == .read}).map({$0.book!}), fetchBooks: false, navigationTitle: "Books You've Read")) {
                        LibrarySectionComponent(title: "Read", systemImage: "book")
                    }
                    .listRowBackground(Color.clear)
                    NavigationLink(destination: AllBooksView(allBooks: booksPutAway.map {$0.book!}, fetchBooks: false, navigationTitle: "Books You've Put Away")) {
                        LibrarySectionComponent(title: "put-away", systemImage: "tray")
                    }
                    .listRowBackground(Color.clear)
                    Section(LocalizedStringKey("Recently read")) {
                        ForEach(books.sorted(by: {$0.lastUpdated > $1.lastUpdated})) { cycle in
                            BookTile(book: cycle.book!)
                        }
                    }
                    Section(LocalizedStringKey("Recently added")) {
                        ForEach(allBooks.sorted(by: {$0.dateAdded! > $1.dateAdded!})) { book in
                            BookTile(book: book)
                        }
                    }
                    
                }
            }.navigationTitle("Library")
        }
    }
    
}

struct BookTile: View {
    var book: Book
    var body: some View {
        NavigationLink(destination: BookView(book: book)) {
            ZStack {
                HStack {
                    ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "", width: 60, height: 90)
                    VStack(alignment: .leading, spacing: 5) {
                        Spacer()
                        Text(book.title!).font(.system(size: 20))
                            .fontWeight(.semibold)
                        Text(Authors(book.authors!).names)
                        Spacer()
                    }
                }
            }
        }
        
    }
}

struct LibrarySectionComponent: View {
    var title: String
    var systemImage: String
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 40, height: 40)
            Text(LocalizedStringKey(title)).font(.title)
            Spacer()
        }
    }
}

struct LibraryViewPreviews: PreviewProvider {
    static var previews: some View {
        let _ = PreviewController().createNewBookForPreview()
        return Group {
            LibraryView()
                .environment(\.managedObjectContext, DataController.preview.context)
            LibraryView()
                .environment(\.managedObjectContext, DataController.preview.context)
                .environment(\.locale, .init(identifier: "de"))
        }
    }
}
