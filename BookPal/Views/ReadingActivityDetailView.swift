//
//  ReadingActivityDetailView.swift
//  BookPal
//
//  Created by Jan Kipka on 31.01.22.
//

import Foundation
import SwiftUI

struct ReadingActivityDetailView: View {
    
    @ObservedObject var readingActivity: ReadingActivity
    var startedAt: String
    var timePassed: String {
        readingActivity.passedTimeUntilNow.asHoursMinutesString
    }
    @State var pagesRead: String = ""
    @State var showMessage: Bool = false
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    init() {
        self.readingActivity = ReadingActivity()
        self.startedAt = ""
        UITableView.appearance().backgroundColor = .clear
    }
    
    init(readingActivity: ReadingActivity){
        self.readingActivity = readingActivity
        self.startedAt = readingActivity.startedAt?.asTimeUnit.asDateStringShort ?? Date().formatted()
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ZStack {
            Colors.mint
                .ignoresSafeArea()
            VStack {
                Form {
                    BookComponent(book: readingActivity.readingCycle!.book!)
                        .padding()
                    Section("Start Date") {
                        Text(startedAt)
                    }
                    Section("Time spent reading") {
                        Text(timePassed)
                    }
                    Section("Started on page") {
                        Text("\(readingActivity.readingCycle?.currentPage ?? 0)")
                    }
                    Section("Pages read") {
                        TextField("What page are you on?", text: $pagesRead)
                    }
                }
                Button("Finish reading") {
                    if pagesRead.isEmpty {
                        showMessage = true
                        return
                    }
                    let onPage = Int16(pagesRead)!
                    readingActivity.finishedActivityOnPage = onPage
                    let onPageBefore = readingActivity.readingCycle?.currentPage ?? 0
                    readingActivity.pagesRead = onPage - onPageBefore
                    readingActivity.readingCycle?.currentPage = onPage
                    readingActivity.finishedAt = Date()
                    readingActivity.active = false
                    dataController.save()
                    dismiss()
                }
                .alert(isPresented: $showMessage) {
                    Alert(title: Text("Please enter the page you are currently on."))
                }
                .disabled(pagesRead.isEmpty)
                .frame(maxWidth: 250, maxHeight: 7)
                .padding(.vertical, 20)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                Spacer()
            }
            
        }.navigationBarTitle("Reading activity")
    }
}
