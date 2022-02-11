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
    
    @FetchRequest(entity: Author.entity(), sortDescriptors: [NSSortDescriptor(key: "lastName", ascending: true)], predicate: NSPredicate(format: "books.@count > 0")) var authors: FetchedResults<Author>
    
    var filteredAuthors: [Author] {
        if searchQuery.isEmpty {
            return Array(authors)
        } else {
            return authors.filter {
                $0.firstName!.contains(searchQuery) || $0.lastName!.contains(searchQuery)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                .ignoresSafeArea()
            List {
                ForEach(filteredAuthors) { author in
                    NavigationLink(destination: BookListView(navigationTitle: "Books by \(author.firstName ?? "") \(author.lastName ?? "")", predicate: NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "ANY authors.lastName = %@", author.lastName!), NSPredicate(format: "ANY authors.firstName = %@", author.firstName!)]))) {
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
    }
}
