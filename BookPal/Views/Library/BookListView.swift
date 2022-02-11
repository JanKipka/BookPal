//
//  AllBooksView.swift
//  BookPal
//
//  Created by Jan Kipka on 02.02.22.
//

import Foundation
import SwiftUI

struct BookListView: View {
    
    @State var searchQuery = ""
    var navigationTitle: String
    @FetchRequest var books: FetchedResults<Book>
    
    init(navigationTitle: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], fetchLimit: Int? = nil) {
        self.navigationTitle = navigationTitle
        let request = Book.fetchRequest()
        if let predicate = predicate {
            request.predicate = predicate
        }
        request.sortDescriptors = sortDescriptors
        if let fetchLimit = fetchLimit {
            request.fetchLimit = fetchLimit
        }
        _books = FetchRequest(fetchRequest: request)
    }
    
    var filteredBooks: [Book] {
        if searchQuery.isEmpty {
            return Array(books)
        } else {
            return books.filter{
                $0.title!.contains(searchQuery) || $0.filterAuthors(searchQuery)
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                .ignoresSafeArea()
            List {
                ForEach(filteredBooks, id: \.isbn) { book in
                    BookComponent(book: book, font: .system(size: 22))
                        .padding(.vertical, 3)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.grouped)
        }.navigationTitle(LocalizedStringKey(navigationTitle))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
    }
}

