//
//  ReadingCycleView.swift
//  BookPal
//
//  Created by Jan Kipka on 29.01.22.
//

import Foundation
import SwiftUI

struct NewReadingCycleView: View {
    
    @State var searchQuery: String = ""
    @State var volumes: [Volume] = []
    @State var selectedVolume: VolumeInfo = VolumeInfo()
    @State var startedAtDate: Date = Date()
    @State var selectionMade = false
    @State var titleAsString: String = ""
    
    @State var apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    
    var body: some View {
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
                    Button("Start reading") {
                        
                    }.disabled(!selectionMade)
                    
                    Section("Search") {
                        TextField("Search for a book...", text: $searchQuery)
                            .onChange(of: searchQuery) { query in
                                if query.count >= 2 {
                                    callApi()
                                }
                            }
                    }
                    
                }
                .padding(.bottom, -50)
                List {
                    ForEach(volumes) { volume in
                        Text(volume.volumeInfo.title!)
                            .onTapGesture {
                                selectedVolume = volume.volumeInfo
                                titleAsString = selectedVolume.title!
                                selectionMade = true
                            }
                    }
                }
                .listStyle(.grouped)
                
            }
            .navigationBarHidden(true)
    }
    
    private func createNewCycle() {
        let readingCycle = ReadingCycle(context: moc)
        readingCycle.startedAt = startedAtDate
        readingCycle.active = true
        readingCycle.id = UUID()
        
        let bookAlreadySaved = !dataController.getAllSavedBooks().map({$0.isbn})
            .filter({selectedVolume.industryIdentifiers!.map({$0.identifier}).contains($0)}).isEmpty
        if (bookAlreadySaved) {
            let book = dataController.getBookByISBN(selectedVolume.industryIdentifiers![0].identifier!)
        } else {
            let book = Book(context: moc)
            for author in selectedVolume.authors! {
                
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
                Text(String("Seitenzahl: \(volumeInfo.pageCount ?? 0)"))
            }
        }
        .onTapGesture(perform: onTap)
    }
    
}
