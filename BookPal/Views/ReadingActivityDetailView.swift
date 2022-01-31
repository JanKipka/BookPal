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
    var timeSpentReading: String {
        readingActivity.timeSpentReading.asHoursMinutesString
    }
    @State var pagesRead: String = ""
    @State var showMessage: Bool = false
    //@State var notes: String = ""
    var viewMode: Bool
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    init(readingActivity: ReadingActivity, viewMode: Bool = false){
        self.readingActivity = readingActivity
        self.viewMode = viewMode
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
                        Text(viewMode ? timeSpentReading : timePassed)
                    }
                    Section("Started on page") {
                        Text("\(readingActivity.startedActivityOnPage)")
                    }
                    Section("Finished on page") {
                        if viewMode {
                            Text("\(readingActivity.finishedActivityOnPage)")
                        } else {
                            TextField("What page are you on?", text: $pagesRead)
                        }
                    }
//                    Section("Notes") {
//                        TextEditor(text: $notes)
//                        //Text("\(readingActivity.notes!)")
//                    }
                }
                if !viewMode {
                    Button("Finish reading") {
                        buttonAction()
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
                }
                
                Spacer()
            }
            
        }.navigationBarTitle("Reading activity")
            .onDisappear {
//                readingActivity.notes = notes
//                dataController.save()
            }
    }
    
    func buttonAction(){
        print("In action")
        if viewMode {
            dismiss()
        } else {
            finishReadingActivity()
        }
    }
    
    func saveReadingActivity() {
        //readingActivity.notes = notes
        dataController.save()
        dismiss()
    }
    
    func finishReadingActivity() {
        if pagesRead.isEmpty {
            showMessage = true
            return
        }
        let onPage = Int16(pagesRead)!
        readingActivity.finishedActivityOnPage = onPage
        let onPageBefore = readingActivity.readingCycle?.currentPage ?? 0
        //readingActivity.startedActivityOnPage = onPageBefore
        readingActivity.pagesRead = onPage - onPageBefore
        readingActivity.readingCycle?.currentPage = onPage
        readingActivity.finishedAt = Date()
        readingActivity.active = false
        //readingActivity.notes = notes
        dataController.save()
        dismiss()
    }
}
