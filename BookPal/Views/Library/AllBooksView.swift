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
    var fetchBooks: Bool = true
    @State var booksToDisplay: [Book] = []
    var navigationTitle: String
    
    
    var body: some View {
        ZStack {
            Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                .ignoresSafeArea()
            List {
                ForEach(booksToDisplay, id: \.isbn) { book in
                    BookComponent(book: book, font: .system(size: 22))
                        .padding(.vertical, 3)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.grouped)
        }.navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
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
                if allBooks.isEmpty && fetchBooks {
                    allBooks = BooksController().getAllSavedBooks()
                }
                booksToDisplay = allBooks
            }
    }
}

