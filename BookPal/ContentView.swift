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
    @Environment(\.managedObjectContext) var moc
    let dataController = DataController.shared
    var user: User {
        users.first!
    }
    @State var bookTitle: String = ""
    @State var genreName: String = ""
    @State var selectedGenre: Genre = Genre()
    var id = UUID()
    
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
                Section("All books") {
                    List(books) { book in
                        Text(book.title ?? "")
                    }
                }
                Button("Delete All") {
                    dataController.deleteAll(entityName: "Genre")
                    dataController.deleteAll(entityName: "Book")
                }
            }
        }.navigationTitle("BookPal")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let dataController = DataController.preview
        
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
