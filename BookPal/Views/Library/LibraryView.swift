//
//  LibraryView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct LibraryView: View {
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "lastRead", ascending: false)], predicate: NSPredicate(format: "lastRead != nil")) var recentlyRead: FetchedResults<Book>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "dateAdded", ascending: false)]) var recentlyAdded: FetchedResults<Book>
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                    .ignoresSafeArea()
                List {
                    NavigationLink(destination: BookListView(navigationTitle: "Books")) {
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
                    NavigationLink(destination: BookListView(navigationTitle: "Books You've Read", predicate: NSPredicate(format: "ANY readingCycles.finishedStatusValue == 0"))) {
                        LibrarySectionComponent(title: "Read", systemImage: "book")
                    }
                    .listRowBackground(Color.clear)
                    NavigationLink(destination: BookListView(navigationTitle: "Books You've Put Away", predicate: NSPredicate(format: "ANY readingCycles.finishedStatusValue == 1"))) {
                        LibrarySectionComponent(title: "put-away", systemImage: "tray")
                    }
                    .listRowBackground(Color.clear)
                    NavigationLink(destination: BookListView(navigationTitle: "favorites", predicate: NSPredicate(format: "isFavorite == true"))) {
                        LibrarySectionComponent(title: "favorites", systemImage: "star")
                    }
                    .listRowBackground(Color.clear)
                    Section(LocalizedStringKey("Recently read")) {
                        ForEach(recentlyRead.prefix(5)) { book in
                            BookTile(book: book)
                        }
                    }
                    Section(LocalizedStringKey("Recently added")) {
                        ForEach(recentlyAdded.prefix(5)) { book in
                            BookTile(book: book)
                        }
                    }
                    
                }
            }.navigationTitle("Library")
        }
        .navigationViewStyle(.stack)
    }
    
}

struct BookTile: View {
    var book: Book
    @State var presentAlert = false
    @State var hasActiveActivityAlert: Bool = false
    let readingController = ReadingController()
    
    var body: some View {
        NavigationLink(destination: BookView(book: book)) {
            ZStack {
                HStack {
                    ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "", width: 60, height: 90)
                    VStack(alignment: .leading, spacing: 5) {
                        Spacer()
                        Text(book.title ?? "").font(.system(size: 20))
                            .fontWeight(.semibold)
                        Text(Authors(book.authors ?? []).names)
                        Spacer()
                    }
                }
            }
        }
        .swipeActions(edge: .leading) {
            BookSwipeActions(book: book, presentAlert: $presentAlert, hasActiveActivityAlert: $hasActiveActivityAlert)
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
                .environment(\.managedObjectContext, DataController.preview.container.viewContext)
            LibraryView()
                .environment(\.managedObjectContext, DataController.preview.container.viewContext)
                .environment(\.locale, .init(identifier: "de"))
        }
    }
}
