//
//  AllBooksView.swift
//  BookPal
//
//  Created by Jan Kipka on 02.02.22.
//

import Foundation
import SwiftUI

struct AllBooksView: View {
    
    @State var searchQuery = ""
    
    @State var allBooks: [Book] = []
    @State var booksToDisplay: [Book] = []
    
    
    var body: some View {
        ZStack {
            Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                .ignoresSafeArea()
            List {
                ForEach(booksToDisplay, id: \.isbn) { book in
                    BookComponent(book: book, font: .title)
                }
            }
            .listStyle(.grouped)
        }.navigationTitle("Books")
            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchQuery) { query in
                if searchQuery.isEmpty {
                    booksToDisplay = allBooks
                } else {
                    booksToDisplay = allBooks.filter{
                        $0.title!.contains(query) || $0.filterAuthors(query)
                    }
                }
            }
            .onAppear {
                if allBooks.isEmpty {
                    allBooks = BooksController().getAllSavedBooks()
                }
                booksToDisplay = allBooks
            }
    }
}
