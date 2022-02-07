//
//  AuthorView.swift
//  BookPal
//
//  Created by Jan Kipka on 03.02.22.
//

import Foundation

import SwiftUI

struct AuthorView: View {
    
    @State var searchQuery = ""
    
    @State var allAuthors: [Author] = []
    @State var authorsToDisplay: [Author] = []
    
    
    var body: some View {
        ZStack {
            Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                .ignoresSafeArea()
            List {
                ForEach(authorsToDisplay) { author in
                    NavigationLink(destination: AllBooksView(allBooks: Array(author.books as! Set<Book>), fetchBooks: false, navigationTitle: "Books by \(author.firstName ?? "") \(author.lastName ?? "")")) {
                        Text("\(author.firstName ?? "") \(author.lastName ?? "")")
                            .font(.title)
                    }
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 10)
                }
            }
            .listStyle(.grouped)
        }.navigationTitle("Authors")
            .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
            .onChange(of: searchQuery) { query in
                if searchQuery.isEmpty {
                    authorsToDisplay = allAuthors
                } else {
                    authorsToDisplay = allAuthors.filter {
                        $0.firstName!.contains(query) || $0.lastName!.contains(searchQuery)
                    }
                }
            }
            .onAppear {
                allAuthors = BooksController().getAllSavedAuthors()
                    .filter({$0.books?.count ?? 0 > 0})
                authorsToDisplay = allAuthors
            }
    }
}
