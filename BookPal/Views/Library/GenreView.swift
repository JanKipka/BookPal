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
            Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                .ignoresSafeArea()
            List {
                ForEach(genresToDisplay) { genre in
                    NavigationLink(destination: AllBooksView(allBooks: Array(genre.books as! Set<Book>), navigationTitle: "\(genre.name ?? "") Books")) {
                        Text(genre.name ?? "")
                            .font(.title)
                    }.listRowBackground(Color.clear)
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
                genresToDisplay = allGenres
            }
    }
}
