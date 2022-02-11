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
    
    @FetchRequest(entity: Genre.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], predicate: NSPredicate(format: "books.@count > 0")) var genres: FetchedResults<Genre>
    
    var filteredGenres: [Genre] {
        if searchQuery.isEmpty {
            return Array(genres)
        } else {
            return genres.filter {
                $0.name!.contains(searchQuery)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                .ignoresSafeArea()
            List {
                ForEach(filteredGenres) { genre in
                    NavigationLink(destination: BookListView(navigationTitle: "\(genre.name ?? "")", predicate: NSPredicate(format: "ANY genre = %@", genre))) {
                        Text(LocalizedStringKey(genre.name ?? ""))
                            .font(.title)
                    }.listRowBackground(Color.clear)
                        .padding(.vertical, 10)
                }
            }
            .listStyle(.grouped)
        }.navigationTitle("Genres")
            .searchable(text: $searchQuery)
    }
}
