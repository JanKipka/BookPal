//
//  ViewComponents.swift
//  BookPal
//
//  Created by Jan Kipka on 30.01.22.
//

import Foundation
import SwiftUI
import UIKit

struct ReadingCycleComponent: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    @ObservedObject var readingCycle: ReadingCycle
    @State var showAlert = false
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                ImageComponent(thumbnail: readingCycle.book?.coverLinks?.thumbnail ?? "", width: 70, height: 75)
                VStack(alignment: .leading, spacing: 5) {
                    Text("\(readingCycle.book?.title ?? "")").font(.system(size: 20))
                        .fontWeight(.semibold)
                    Text(Authors((readingCycle.book?.authors) ?? []).names)
                    Spacer()
                    if readingCycle.active {
                        HStack {
                            Text("on-page-of \(Int(readingCycle.currentPage)) \(Int(readingCycle.book?.numOfPages ?? 0))")
                            Spacer()
                            Text(readingCycle.hasActiveActivities ? "Reading" : readingCycle.readingActivities?.count == 0 ? "" : LocalizedStringKey("done-in \(readingCycle.remainingTime?.asDaysHoursMinutesString ?? "??m")"))
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                        .font(.callout)
                    }
                }
            }
        }
    }
}

struct ImageComponent: View {
    var thumbnail: String
    var width: CGFloat = 60
    var height: CGFloat = 60
    
    var body: some View {
        AsyncImage(url: URL(string: thumbnail)){ image in
            image.resizable()
        } placeholder: {
            Image("placeholder")
                .resizable()
                .frame(width: width, height: height, alignment: .center)
        }
        .cornerRadius(5)
        .aspectRatio(contentMode: .fit)
        .frame(width: width, height: height, alignment: .center)
    }
}



struct ReadingActivityComponent: View {
    
    @ObservedObject var readingActivity: ReadingActivity
    
    var body: some View {
        VStack (spacing: 10){
            HStack {
                ImageComponent(thumbnail: readingActivity.readingCycle?.book?.coverLinks?.thumbnail ?? "")
                VStack(alignment: .leading, spacing: 5) {
                    TimelineView(.everyMinute) { context in
                        Text("\(readingActivity.passedTimeFromDateSinceStart(context.date).asDaysHoursMinutesString )")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    Text("\(readingActivity.readingCycle?.book?.title ?? "")").font(.headline)
                }
            }
        }
    }
}

struct BookComponent: View {
    
    @State var book: Book
    @State var authors: Authors
    var font: Font?
    
    init(book: Book) {
        self.init(book: book, font: .headline)
    }
    
    init(book: Book, font: Font) {
        self.book = book
        self.authors = Authors(book.authors!)
        self.font = font
    }
    
    var body: some View {
        HStack {
            ImageComponent(thumbnail: book.coverLinks?.thumbnail ?? "")
            VStack(alignment: .leading, spacing: 5) {
                Text("\(book.title ?? "")").font(font)
                Text("\(authors.names)")
            }
        }
    }
    
}

struct ReadingActivityListComponent: View {
    
    @ObservedObject var ac: ReadingActivity
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                TimelineView(.everyMinute) { context in
                    Text("\(ac.active ? ac.passedTimeFromDateSinceStart(context.date).asDaysHoursMinutesString : ac.timeSpentReading.asDaysHoursMinutesString )")
                }
                
                Spacer()
                Text(getPagesString(readingActivitiy:ac))
            }
            HStack {
                Text(ac.startedAt?.asLocalizedStringHoursMinutes ?? "")
                    .font(.caption)
                Spacer()
                Text(ac.finishedAt?.asLocalizedStringHoursMinutes ?? "")
                    .font(.caption)
            }
        }
        .listRowBackground(ac.active ? Color.orangeAccent2 : .white)
        .padding(.vertical)
    }
    
    func getPagesString(readingActivitiy: ReadingActivity) -> LocalizedStringKey {
        return readingActivitiy.active ? LocalizedStringKey("active") : LocalizedStringKey("\(Int(readingActivitiy.pagesRead)) pages")
    }
    
}

struct GradientProgressBarStyle: ProgressViewStyle {
    
    var height: Int = 20

    func makeBody(configuration: Configuration) -> some View {
        let fraction = configuration.fractionCompleted ?? 0
        ZStack {
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 8)
                    .foregroundColor(.white)
                    .frame(width: geo.size.width, height: CGFloat(height))
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: [.blue, .mint], startPoint: .leading, endPoint: .trailing))
                    .frame(width: geo.size.width * fraction, height: CGFloat(height))
                RoundedRectangle(cornerRadius: 8).stroke(Color.gray)
                    .frame(width: geo.size.width, height: CGFloat(height))
                VStack(alignment: .center) {
                    configuration.label?.foregroundColor(Color.black)
                }.frame(width: geo.size.width, height: CGFloat(height))
            }
        }
    }
}

struct CircularProgressBarStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            GeometryReader { geo in
                Circle()
                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 2, dash: [10]))
                Circle()
                    .trim(from: 0, to: configuration.fractionCompleted ?? 0)
                    .stroke(LinearGradient(colors: [.blue, .mint], startPoint: .trailing, endPoint: .leading), style: StrokeStyle(lineWidth: geo.size.width / 5))
                    .rotationEffect(Angle(degrees: -90))
            }
        }
        .padding()
    }
}

// PREVIEWS

struct ProgressBarPreviews: PreviewProvider {
    static var previews: some View {
        VStack {
            ProgressView("Test", value: 0.98, total: 1)
                .progressViewStyle(GradientProgressBarStyle(height: 25))
            
            
            List {
                ProgressView("Test", value: 0.98, total: 1)
                    .progressViewStyle(GradientProgressBarStyle())
                HStack {
                    ProgressView(value: 0.5, total: 1)
                        .progressViewStyle(CircularProgressBarStyle())
                        .frame(width: 65, height: 65)
                    Text("Test")
                }
            }
        }
        
    }
}

//struct ImageComponentPreviews: PreviewProvider {
//    static var previews: some View {
//        ImageComponent(thumbnail: "https://assets.thalia.media/img/artikel/537d8abe0db2fc7bccb7a989a135a06553028624-00-00.jpeg", width: 100, height: 180)
//    }
//
//}
//
//struct ReadingActivityListComponentPreviews: PreviewProvider {
//
//    static var previews: some View {
//        let ac = PreviewController().createActiveRunningReadingActivity()
//        return ReadingActivityListComponent(ac: ac)
//    }
//}
//
//struct BookComponentPreviews: PreviewProvider {
//    static var previews: some View {
//        let book = PreviewController().createNewBookForPreview()
//        return List {
//            BookComponent(book: book)
//        }
//        .listStyle(.grouped)
//    }
//}
