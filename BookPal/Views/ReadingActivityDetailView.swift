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
    @State var endDate: Date = Date()
    @State var timeSpentReadingString: String = ""
    var timePassed: String {
        readingActivity.passedTimeUntilNow.asHoursMinutesString
    }
    var timeSpentReading: String {
        readingActivity.timeSpentReading.asHoursMinutesString
    }
    @State var pagesRead: String = ""
    @State var showMessage: Bool = false
    @State var notes: String = ""
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.dismiss) var dismiss
    
    let dataController = DataController.shared
    
    var body: some View {
        ZStack {
            Colors.mint
                .ignoresSafeArea()
            VStack {
                Form {
                    BookComponent(book: readingActivity.readingCycle!.book!)
                        .padding()
                    Section("Start Date") {
                        Text(readingActivity.startedAt?.asLocalizedStringHoursMinutes ?? Date().formatted())
                    }
                    if !readingActivity.active {
                        Section("End Date") {
                            DatePicker("End Date", selection: $endDate)
                                .onChange(of: endDate) { d in
                                    let interval = d.timeIntervalSince(readingActivity.startedAt!)
                                    self.timeSpentReadingString = getTimeUnitFromTimeInterval(interval).asHoursMinutesString
                                }
                        }
                    }
                    Section("Time spent reading") {
                        Text(timeSpentReadingString)
                    }
                    Section("Started on page") {
                        Text("\(readingActivity.startedActivityOnPage)")
                    }
                    Section("Finished on page") {
                        if !readingActivity.active {
                            Text("\(readingActivity.finishedActivityOnPage)")
                        } else {
                            TextField("What page are you on?", text: $pagesRead)
                        }
                    }
                    Section("Notes") {
                        TextEditor(text: $notes)
                    }
                }
                if readingActivity.active {
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
                } else {
                    Button("Save") {
                        buttonAction()
                    }
                    .frame(maxWidth: 250, maxHeight: 7)
                    .padding(.vertical, 20)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                
                Spacer()
            }
            
        }.navigationTitle("Reading activity")
            .onAppear {
                self.endDate = readingActivity.finishedAt ?? Date()
                self.notes = readingActivity.notes ?? ""
                self.timeSpentReadingString = !readingActivity.active ? timeSpentReading : timePassed
            }
    }
    
    func buttonAction(){
        if !readingActivity.active {
            readingActivity.notes = notes
            readingActivity.finishedAt = endDate
            dataController.save()
            dismiss()
        } else {
            finishReadingActivity()
        }
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
        readingActivity.notes = notes
        dataController.save()
        dismiss()
    }
}
