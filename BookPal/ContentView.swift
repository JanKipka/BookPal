//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: []) var users: FetchedResults<User>
    @FetchRequest(sortDescriptors: []) var books: FetchedResults<Book>
    @FetchRequest(sortDescriptors: []) var genres: FetchedResults<Genre>
    @FetchRequest(sortDescriptors: []) var cycles: FetchedResults<ReadingCycle>
    @Environment(\.managedObjectContext) var moc
    let dataController = DataController.shared
    var user: User {
        users.first!
    }
    @State var bookTitle: String = ""
    @State var genreName: String = ""
    @State var selectedGenre: Genre = Genre()
    @State var selectedBook: Book = Book()
    @State var activeCycles: [ReadingCycle] = []
    
    var body: some View {
        NavigationView {
            Form {
                Section("Genre") {
                    TextField("Genre name", text: $genreName)
                    Button("Add Genre") {
                        let genre = Genre(context: moc)
                        genre.id = UUID()
                        genre.name = genreName
                        dataController.save()
                        genreName = ""
                    }
                }
                Section("Books") {
                    TextField("Book title", text: $bookTitle)
                    Picker("Genre", selection: $selectedGenre) {
                        ForEach(genres, id: \.self.id) { genre in
                            Text(genre.name ?? "").tag(genre)
                        }
                    }
                    Button("Add book") {
                        if let genre = genres.first(where: {$0 == selectedGenre}) {
                            let book = Book(context: moc)
                            book.id = UUID()
                            book.title = bookTitle
                            book.genre = genre
                            book.isbn = String(Int.random(in: 12312...1231231))
                            user.addToBooks(book)
                            dataController.save()
                            bookTitle = ""
                        } else {
                            print("No genre found")
                        }
                    }
                }
                Section("Reading cycles") {
                    Picker("Book", selection: $selectedBook) {
                        ForEach(books, id: \.self) { book in
                            Text(book.title ?? "").tag(book)
                        }
                    }
                    Button("Add reading cycle") {
                        let cycle = ReadingCycle(context: moc)
                        cycle.startedAt = Date()
                        cycle.active = true
                        cycle.book = selectedBook
                        cycle.id = UUID()
                        dataController.save()
                        activeCycles = filterCycles()
                    }
                    List(activeCycles) {
                        Text(formatDate($0.startedAt ?? Date()))
                    }
                }
                Button("Delete All") {
                    dataController.deleteAll(entityName: "Genre")
                    dataController.deleteAll(entityName: "Book")
                    dataController.deleteAll(entityName: "ReadingCycle")
                }
            }
        }.navigationTitle("BookPal").onAppear() {
            activeCycles = filterCycles()
        }
    }
    
    func filterCycles() -> [ReadingCycle] {
        return cycles.filter({$0.active})
    }
    
    func formatDate(_ d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: d)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let dataController = DataController.preview
        
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
