//
//  ReadingCycleView.swift
//  BookPal
//
//  Created by Jan Kipka on 29.01.22.
//

import Foundation
import SwiftUI

struct NewReadingCycleView: View {
    
    @State var selectedVolume: VolumeInfo = VolumeInfo()
    @State var startedAtDate: Date = Date()
    @State var titleAsString: String = ""
    @State var showingAlert = false
    @State var readingCycle = ReadingCycle()
    @State var showSearchSheet = false
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Colors.mint
                .ignoresSafeArea()
            VStack {
                Form {
                    Section("Dates") {
                        DatePicker("Start Date", selection: $startedAtDate)
                            .padding(.horizontal, 10)
                    }
                    Section("Book") {
                        TextField("Book Choice", text: $titleAsString)
                            .disabled(true)
                    }
                    Section("Search") {
                        Button("Search for a Book") {
                            showSearchSheet.toggle()
                        }
                        .sheet(isPresented: $showSearchSheet, onDismiss: {
                            titleAsString = selectedVolume.title ?? ""
                        }){
                            SearchView(selectedVolume: $selectedVolume)
                        }
                    }
                    
                    Button("Start reading!") {
                        createNewCycle()
                    }.disabled(titleAsString == "")
                }
                .background(.clear)
                .padding(.bottom)
                
                
            }
            .alert(isPresented: $showingAlert) {
                presentAlert()
            }
            .onAppear {
                self.startedAtDate = Date()
            }
            
        }.navigationBarTitle("Add a book")
    }
    
    private func presentAlert() -> Alert {
        Alert(
            title: Text("The book was added. Do you want to start reading now?"),
            primaryButton: .default(Text("Yes")) {
                let readingActivity = ReadingActivity(context: moc)
                readingActivity.id = UUID()
                readingActivity.startedAt = Date()
                readingActivity.readingCycle = readingCycle
                readingActivity.startedActivityOnPage = 0
                readingActivity.active = true
                dataController.save()
                navigateBack()
            },
            secondaryButton: .default(Text("No")) {
                navigateBack()
            }
        )
    }
    
    private func createNewCycle() {
        readingCycle = ReadingCycle(context: moc)
        readingCycle.startedAt = startedAtDate
        readingCycle.active = true
        readingCycle.id = UUID()
        let isbn = selectedVolume.industryIdentifiers![0].identifier! // for now always use the first available isbn
        if let book = dataController.getBookByISBN(isbn) {
            // already existing
            readingCycle.book = book
        } else {
            // add new book
            let book = Book(context: moc)
            for author in selectedVolume.authors! {
                let names = author.split(separator: " ")
                if let aut = dataController.searchForPotentialAuthorMatch(firstName: String(names.first ?? ""), lastName: String(names.last ?? "")) {
                    book.addToAuthors(aut)
                } else {
                    let aut = Author(context: moc)
                    aut.id = UUID()
                    aut.firstName = names.dropLast().joined(separator: " ")
                    aut.lastName = String(names.last ?? "")
                    book.addToAuthors(aut)
                }
            }
            book.isbn = isbn
            book.title = selectedVolume.title!
            book.numOfPages = Int16(selectedVolume.pageCount!)
            let genreString = selectedVolume.mainCategory ?? selectedVolume.categories?.first ?? ""
            if let genre = dataController.searchForGenreByString(genreString) {
                book.genre = genre
            } else {
                if !genreString.isEmpty {
                    let genre = Genre(context: moc)
                    genre.name = genreString
                    book.genre = genre
                }
            }
            if let links = selectedVolume.imageLinks {
                let covers = CoverLinks(context: moc)
                covers.thumbnail = links.thumbnail
                covers.small = links.small
                covers.medium = links.medium
                covers.large = links.large
                book.coverLinks = covers
            }
            readingCycle.book = book
        }
        dataController.save()
        showingAlert = true
    }
    
    private func navigateBack() {
        dismiss()
    }
    
}

struct SearchView: View {
    
    @State var searchQuery: String = ""
    @State var volumes: [Volume] = []
    @Binding var selectedVolume: VolumeInfo
    @State var apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search for a book...", text: $searchQuery)
                    .onChange(of: searchQuery) { query in
                        if query.count >= 2 {
                            callApi()
                        }
                    }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            
            List {
                ForEach(volumes) { volume in
                    VolumeInfoView(volumeInfo: volume.volumeInfo) {
                        selectedVolume = volume.volumeInfo
                        dismiss()
                    }
                }
            }
            .listStyle(.grouped)
            
        }.padding()
    }
    
    private func callApi() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            do {
                try apiController.queryForBooks(searchQuery) { (results) in
                    volumes = performQualityFilter(results)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func performQualityFilter(_ values: [Volume]) -> [Volume] {
        return values.filter({$0.volumeInfo.title != nil})
            .filter({$0.volumeInfo.pageCount != nil})
            .filter({$0.volumeInfo.authors != nil})
            .filter({$0.volumeInfo.categories != nil})
            .filter({$0.volumeInfo.industryIdentifiers != nil && $0.volumeInfo.industryIdentifiers!.count > 0})
    }
}

struct VolumeInfoView: View {
    
    let volumeInfo: VolumeInfo
    let onTap: () -> Void
    
    init(volumeInfo: VolumeInfo, onTap: @escaping () -> Void) {
        self.volumeInfo = volumeInfo
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            if let url = volumeInfo.imageLinks?.thumbnail {
                AsyncImage(url: URL(string: url)){ image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50, alignment: .leading)
            } else {
                Image("placeholder")
                    .resizable()
                    .frame(width: 50, height: 50, alignment: .leading)
            }
            VStack(alignment: .leading) {
                Text(volumeInfo.title ?? "").fontWeight(.bold)
                Text(String("Page Count: \(volumeInfo.pageCount ?? 0)"))
            }
        }
        .onTapGesture(perform: onTap)
    }
    
}
