//
//  ReadingCycleView.swift
//  BookPal
//
//  Created by Jan Kipka on 29.01.22.
//

import Foundation
import SwiftUI

struct AddBookView: View {
    
    @Binding var selectedVolume: VolumeInfo
    @State var startedAtDate: Date = Date()
    @Binding var titleAsString: String
    @State var showingAlert = false
    @State var showingAlertAlreadyActive = false
    @State var showingAlreadyAddedAlert = false
    @State var readingCycle = ReadingCycle()
    @State var showSearchSheet = false
    @State var searchQuery = ""
    @State var book: Book?
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "active = true")) var activities: FetchedResults<ReadingActivity>
    
    @Environment(\.dismiss) var dismiss
    
    let booksController = BooksController()
    let readingController = ReadingController()
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.linearGradient(topColor: Colors.mint, bottomColor: Colors.lighterMint)
                    .ignoresSafeArea()
                VStack {
                    List {
                        if !titleAsString.isEmpty {
                            HStack {
                                ImageComponent(thumbnail: selectedVolume.imageLinks?.thumbnail ?? "")
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(titleAsString).font(.headline)
                                    Text(selectedVolume.authors?.joined(separator: ", ") ?? "")
                                }
                            }
                        }
                        Button {
                            showSearchSheet.toggle()
                        }
                    label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("search")
                            Spacer()
                        }
                    }
                    .sheet(isPresented: $showSearchSheet, onDismiss: {
                        titleAsString = selectedVolume.title ?? ""
                    }){
                        SearchView(selectedVolume: $selectedVolume)
                    }
                        Section {
                            Button("add") {
                                createNewCycle()
                            }.disabled(titleAsString == "")
                                .foregroundColor(.white)
                                .background(.blue)
                                .listRowBackground(Color.blue)
                        }
                    }
                    .background(.clear)
                    .padding(.bottom)
                    
                    
                }
                .alert(isPresented: $showingAlert) {
                    presentAlert()
                }
                .alert("already-active", isPresented: $showingAlertAlreadyActive) {
                    Button("OK") {
                        navigateBack()
                    }
                }
                .alert("book-already-added", isPresented: $showingAlreadyAddedAlert) {
                    Button("OK") {}
                }
                .onAppear {
                    self.startedAtDate = Date()
                }
                .navigationTitle(LocalizedStringKey("Add a book"))
            }
        }
    }
    
    private func presentAlert() -> Alert {
        Alert(
            title: Text("book-added"),
            primaryButton: .default(Text("Yes")) {
                if !activities.isEmpty {
                    showingAlertAlreadyActive.toggle()
                } else {
                    readingCycle = readingController.createNewReadingCycle(book: book!, startedOn: startedAtDate)
                    let _ = readingController.createNewActivity(readingCycle: readingCycle)
                    navigateBack()
                }
            },
            secondaryButton: .default(Text("No")) {
                navigateBack()
            }
        )
    }
    
    private func createNewCycle() {
        let isbn = selectedVolume.industryIdentifiers![0].identifier! // for now always use the first available isbn
        book = booksController.getBookByISBN(isbn)
        if book == nil {
            book = booksController.createNewBookFromVolume(selectedVolume)
            showingAlert = true
        } else {
            showingAlreadyAddedAlert = true
        }
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
    @State var selection: SearchMode = .query
    
    var body: some View {
        NavigationView {
            ZStack {
                Colors.lighterOrange.ignoresSafeArea()
                VStack {
                    List {
                        Section(LocalizedStringKey("Search Mode")) {
                            Picker("Search Mode", selection: $selection) {
                                ForEach(SearchMode.allCases, id: \.self) { mode in
                                    Text(mode.localizedName)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        Group {
                            ForEach(volumes) { volume in
                                VolumeInfoView(volumeInfo: volume.volumeInfo) {
                                    selectedVolume = volume.volumeInfo
                                    dismiss()
                                }
                            }
                        }
                    }
                    .listStyle(.grouped)
                    .padding(.top, -30)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
        }
        .searchable(text: $searchQuery, placement: .navigationBarDrawer(displayMode: .always))
        .onChange(of: searchQuery) { query in
            if query.count >= 2 {
                callApi()
            }
        }
        
        
    }
    
    private func callApi() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            do {
                try apiController.queryForBooks(searchQuery, searchMode: selection) { (results) in
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
