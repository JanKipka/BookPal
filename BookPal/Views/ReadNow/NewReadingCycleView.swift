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
    @State var showingAlertAlreadyActive = false
    @State var readingCycle = ReadingCycle()
    @State var showSearchSheet = false
    @State var searchQuery = ""
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "active = true")) var activities: FetchedResults<ReadingActivity>
    
    @Environment(\.dismiss) var dismiss
    
    let booksController = BooksController()
    let readingController = ReadingController()
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Colors.linearGradient(topColor: Colors.mint, bottomColor: Colors.lighterMint)
                .ignoresSafeArea()
            VStack {
                Form {
                    Section("") {
                        DatePicker("Start Date", selection: $startedAtDate)
                            .padding(.horizontal, 10)
                    }
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
                        Button("Start reading") {
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
            .onAppear {
                self.startedAtDate = Date()
            }
            .navigationTitle(LocalizedStringKey("Add a book"))
        }
    }
    
    private func presentAlert() -> Alert {
        Alert(
            title: Text("book-added"),
            primaryButton: .default(Text("Yes")) {
                if !activities.isEmpty {
                    showingAlertAlreadyActive.toggle()
                    readingCycle.active = false
                    readingController.save()
                } else {
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
        var book = booksController.getBookByISBN(isbn)
        if book == nil {
            book = booksController.createNewBookFromVolume(selectedVolume)
        }
        readingCycle = readingController.createNewReadingCycle(book: book!, startedOn: startedAtDate)
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
        NavigationView {
            ZStack {
                Colors.lighterOrange.ignoresSafeArea()
                VStack {
                    List {
                        ForEach(volumes) { volume in
                            VolumeInfoView(volumeInfo: volume.volumeInfo) {
                                selectedVolume = volume.volumeInfo
                                dismiss()
                            }
                        }
                    }
                    .padding(.top, 5)
                    .listStyle(.grouped)
                }
            }
            .navigationTitle("Search")
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

struct NewReadingCycleViewPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewReadingCycleView()
                .environment(\.locale, .init(identifier: "de"))
        }
    }
}
