//
//  BookView.swift
//  BookPal
//
//  Created by Jan Kipka on 03.02.22.
//

import Foundation
import SwiftUI

struct BookView: View {
    @ObservedObject var book: Book
    
    init(book: Book) {
        self.book = book
        UILabel.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).adjustsFontSizeToFitWidth = true
    }
    
    var body: some View {
        ZStack {
            List {
                BookDetailsComponent(book: book)
                Divider()
                    .listRowSeparator(.hidden)
                Group {
                    Text("Your History")
                        .font(.title)
                        .fontWeight(.bold)
                    if book.readingCyclesAsArray.filter {$0.active}.count > 0 {
                        Text("currently-reading")
                            .foregroundColor(.blue)
                    }
                    Text("read-times \(book.readingCyclesAsArray.filter({$0.finishedStatus == .read}).count).")
                    if !book.readingCyclesAsArray.filter { $0.finishedStatus == .stopped }.isEmpty {
                        Text("put-away-times \(book.readingCyclesAsArray.filter { $0.finishedStatus == .stopped }.count).")
                    }
                    TimelineView(.everyMinute) { _ in
                        Text("You've spent \(book.totalTimeSpentReading.asDaysHoursMinutesString ) reading this book.")
                    }
                    Text("Logs")
                        .font(.title2)
                        .fontWeight(.semibold)
                    ForEach(book.readingCyclesAsArray) { cycle in
                        ReadingCycleDetailComponent(cycle: cycle)
                    }
                    .listRowSeparator(.visible)
                }
                .listRowSeparator(.hidden)
                .padding(.leading, 10)
                
                
            }
            .listStyle(.grouped)
            
        }.navigationTitle(book.title!)
        
    }
}

struct ReadingCycleDetailComponent: View {
    @ObservedObject var cycle: ReadingCycle
    
    var body: some View {
        NavigationLink(destination: ReadingCycleDetailView(readingCycle: cycle)) {
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(cycle.avgPagesPerMinute.asDecimalString)")
                        Text("Pages per Minute").font(.caption)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 5) {
                        TimelineView(.everyMinute) { _ in
                            Text("\(cycle.totalTimeSpentReading.asDaysHoursMinutesString )")
                        }
                        Text("Total time reading").font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct BookDetailsComponent: View {
    
    @ObservedObject var book: Book
    @State var showDetailsSheet: Bool = false
    
    var body: some View {
        HStack {
            ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "", width: 120, height: 180)
            VStack(alignment: .leading, spacing: 10){
                Text(Authors(book.authors!).names).font(.system(size: 24))
                    .fontWeight(.semibold)
                Spacer()
                Spacer()
                Text("\(Int(book.numOfPages)) pages")
                Text(LocalizedStringKey(book.genre?.name ?? ""))
                Text(book.isbn!)
                    .onTapGesture {
                        UIPasteboard.general.string = book.isbn!
                    }
                Button("more-info") {
                    showDetailsSheet.toggle()
                }
                .sheet(isPresented: $showDetailsSheet) {
                    BookDetailsSheet(book: book)
                }
                Spacer()
            }
            .font(.system(size: 18))
        }
        .padding(.leading, 8)
        .listRowSeparator(.hidden)
        
    }
}

struct BookDetailsSheet: View {
    @State var numOfPagesString: String = ""
    var book: Book
    
    init(book: Book) {
        self.book = book
        _numOfPagesString = State(initialValue: String(book.numOfPages))
    }
    
    var body: some View {
        VStack {
            Form {
                Text(book.title!)
                    .fontWeight(.semibold)
                if !(book.subtitle ?? "").isEmpty {
                    Text(book.subtitle!)
                        .font(.subheadline)
                }
                Section(LocalizedStringKey("Author")) {
                    Text(Authors(book.authors!).names)
                }
                Section(LocalizedStringKey("Publishing")) {
                    Text(book.publisher ?? "")
                    Text("\(book.publishedDate?.formatted(date: .abbreviated, time: .omitted) ?? "")")
                }
                
                Section(LocalizedStringKey("desc")) {
                    Text(book.desc ?? "")
                        .font(.callout)
                }
                Section("isbn") {
                    Text(book.isbn ?? "")
                }
                Section(LocalizedStringKey("pages")) {
                    HStack {
                        TextField(text: $numOfPagesString) {}
                        .onChange(of: numOfPagesString) { pages in
                            book.numOfPages = Int16(pages)!
                        }
                       
                    }
                    
                }
                Text(LocalizedStringKey("info-info"))
                    .font(.caption)
                    .listRowSeparator(.hidden)
            }
            
        }
        
    }
}

struct BookViewPreviews: PreviewProvider {
    static var previews: some View {
        let book = PreviewController().createNewBookForPreview()
        return Group {
            NavigationView {
                BookView(book: book)
            }
            .environment(\.locale, .init(identifier: "de"))
            NavigationView {
                BookView(book: book)
            }
            .previewDevice("iPhone SE (2nd generation)")
        }
        
    }
}
