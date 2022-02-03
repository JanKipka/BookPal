//
//  BookView.swift
//  BookPal
//
//  Created by Jan Kipka on 03.02.22.
//

import Foundation
import SwiftUI

struct BookView: View {
    var book: Book
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
                    Text("You've read this book \(generateTimesString(count:book.readingCyclesAsArray.filter({$0.finishedStatus == .read}).count)).")
                    Text("You've spent \(book.averageTotalTimeSpentReading.asDaysHoursMinutesString ?? "0m") reading this book.")
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
    
    func generateTimesString(count: Int) -> String {
        switch count {
        case 1: return "once"
        case 2: return "twice"
            
        default:
            return "\(count) times"
        }
        
        
    }
}

struct ReadingCycleDetailComponent: View {
    @State var cycle: ReadingCycle
    
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
                        Text("\(cycle.totalTimeSpentReading?.asHoursMinutesString ?? "")")
                        Text("Total time reading").font(.caption)
                    }
                }
            }
        }
        .padding(.vertical, 20)
    }
}

struct BookDetailsComponent: View {
    
    var book: Book
    
    var body: some View {
        HStack {
            ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "", width: 120, height: 180)
            VStack(alignment: .leading, spacing: 10){
                Text(Authors(book.authors!).names).font(.system(size: 24))
                    .fontWeight(.semibold)
                Spacer()
                Spacer()
                Text("\(book.numOfPages) pages")
                Text("\(book.genre?.name ?? "")")
                Text(book.isbn!)
                    .onTapGesture {
                        UIPasteboard.general.string = book.isbn!
                    }
                Spacer()
            }
            .font(.system(size: 18))
        }
        .padding(.leading, 8)
        .listRowSeparator(.hidden)
    }
}

struct BookViewPreviews: PreviewProvider {
    static var previews: some View {
        let book = PreviewController().createNewBookForPreview()
        return Group {
            NavigationView {
                BookView(book: book)
            }
            NavigationView {
                BookView(book: book)
            }
            .previewDevice("iPhone SE (2nd generation)")
        }
        
    }
}
