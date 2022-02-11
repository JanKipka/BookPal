//
//  GenreView.swift
//  BookPal
//
//  Created by Jan Kipka on 03.02.22.
//

import Foundation

import SwiftUI

struct GenreView: View {
    
    @State var searchQuery = ""
    
    @State var allGenres: [Genre] = []
    @State var genresToDisplay: [Genre] = []
    
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                .ignoresSafeArea()
            List {
                ForEach(genresToDisplay) { genre in
                    NavigationLink(destination: BookListView(allBooks: Array(genre.books as! Set<Book>), fetchBooks: false, navigationTitle: "\(genre.name ?? "")")) {
                        Text(LocalizedStringKey(genre.name ?? ""))
                            .font(.title)
                    }.listRowBackground(Color.clear)
                        .padding(.vertical, 10)
                }
            }
            .listStyle(.grouped)
        }.navigationTitle("Genres")
            .searchable(text: $searchQuery)
            .onChange(of: searchQuery) { query in
                if searchQuery.isEmpty {
                    genresToDisplay = allGenres
                } else {
                    genresToDisplay = allGenres.filter{
                        $0.name!.contains(query)
                    }
                }
            }
            .onAppear {
                allGenres = BooksController().getAllSavedGenres()
                    .filter({$0.books?.count ?? 0 > 0})
                genresToDisplay = allGenres
            }
    }
}
