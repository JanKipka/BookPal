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
                    Section("Recently read") {
                        ForEach(books.sorted(by: {$0.lastUpdated > $1.lastUpdated})) { cycle in
                            BookTile(book: cycle.book!)
                        }
                    }
                    Section("Recently added") {
                        ForEach(books.sorted(by: {$0.startedAt! > $1.startedAt!})) { cycle in
                            BookTile(book: cycle.book!)
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
        .padding(.vertical, 8)
    }
}

struct LibrarySectionComponent: View {
    var title: String
    var systemImage: String
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .frame(width: 40, height: 40)
            Text(title).font(.title)
            Spacer()
        }
    }
}
