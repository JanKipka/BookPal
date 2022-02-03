//
//  LibraryView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct LibraryView: View {
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: "completedOn", ascending: false)
    ], predicate: NSPredicate(format: "finishedStatusValue = 0")) var books: FetchedResults<ReadingCycle>
    
    @State var pairs: [[Book]] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                    .ignoresSafeArea()
                //Image("library")
                    //.ignoresSafeArea()
                List {
                    NavigationLink(destination: AllBooksView()) {
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
                    Text("Recently read").font(.system(size: 24))
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                        .padding(.bottom, 5)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.visible, edges: .bottom)
                    ForEach(books) { cycle in
                        BookTile(book: cycle.book!)
                            //.listRowBackground(Color.white.opacity(0.3))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.visible, edges: [.top, .bottom])
                    }
                }
                .listStyle(.grouped)
            }.navigationTitle("Library")
                //.foregroundColor(.white)
        }
        
        // TODO
        // Template: Apple Podcast App -> Library Tab
        // At the top, a menu with Genre, Authors, All
        // Below tiles with recently read books
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
