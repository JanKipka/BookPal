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
    @State var selectedVolume: VolumeInfo
    @State var startedAtDate: Date = Date()
    
    var body: some View {
        VStack {
            DatePicker("Started at", selection: $startedAtDate)
            Spacer()
            TextField("Search for a book...", text: $searchQuery)
                .onChange(of: searchQuery) { _ in
                        // TODO
                }
            List {
                ForEach(volumes) { volume in
                    VolumeInfoView(volumeInfo: volume.volumeInfo)
                }
            }
            .listStyle(GroupedListStyle())
        }
    }
    
    private func callApi() async {
        do {
            try await GoogleBooksAPIController().queryForBooks(searchQuery) { (results) in
                volumes = results
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
}

struct VolumeInfoView: View {

    let volumeInfo: VolumeInfo

    init(volumeInfo: VolumeInfo) {
        self.volumeInfo = volumeInfo
    }

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: volumeInfo.imageLinks?.thumbnail ?? "https://user-images.githubusercontent.com/101482/29592647-40da86ca-875a-11e7-8bc3-941700b0a323.png"))
                .frame(width: 100, height: 100, alignment: .leading)

            VStack(alignment: .leading) {
                Text(volumeInfo.title ?? "")
                Text(String("Seitenzahl: \(volumeInfo.pageCount ?? 0)"))
            }
        }
    }

}
