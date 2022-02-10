//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI
import Foundation
import CoreData

struct ReadNowView: View {
    
    init(){
        UITableView.appearance().backgroundColor = .clear
    }
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: #keyPath(ReadingCycle.startedAt), ascending: true)
    ], predicate: NSPredicate(format: "active = true")) var cycles: FetchedResults<ReadingCycle>
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: #keyPath(ReadingActivity.startedAt), ascending: true)
    ], predicate: NSPredicate(format: "active = true")) var activities: FetchedResults<ReadingActivity>
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    let readingController = ReadingController()
    
    @State var id: UUID = UUID()
    
    let apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    @State var navigateToNewCycleView: Bool = false
    @State var navigateToActivityView: Bool = false
    @State var activityStartedAlert: Bool = false
    @State var hasActiveActivityAlert: Bool = false
    @State var showCancelWarning: Bool = false
    @State var selectedActivity: ReadingActivity?
    @State var selectedCycleToStop: ReadingCycle?
    @State var showSearchSheet = false
    @State var titleAsString = ""
    @State var selectedVolume: VolumeInfo = VolumeInfo()
    @State var searchMode: SearchMode = .query
    
    func startReadingActivityForCycle(_ cycle: ReadingCycle) {
        let hasActiveActivities = !activities.isEmpty
        if hasActiveActivities {
            hasActiveActivityAlert.toggle()
            return
        }
        let _ = readingController.createNewActivity(readingCycle: cycle, onPage: cycle.currentPage)
        activityStartedAlert.toggle()
    }
    
    fileprivate func putBookAway(_ cycle: ReadingCycle) {
        readingController.stopReading(cycle: cycle)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.linearGradient(topColor: Color.primaryColor, bottomColor: Color.secondaryColor)
                    .ignoresSafeArea()
                VStack {
                    List {
                        Section(LocalizedStringKey("active-activities")) {
                            ForEach(activities) { ac in
                                Button {
                                    selectedActivity = ac
                                } label: {
                                    ReadingActivityComponent(readingActivity: ac)
                                }
                                .foregroundColor(.primary)
                                .sheet(item: $selectedActivity) { activity in
                                    ReadingActivityDetailView(readingActivity: activity)
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        selectedActivity = ac
                                    } label: {
                                        Label("finish", systemImage: "checkmark.circle.fill")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        
                        Section(LocalizedStringKey("books-reading")) {
                            ForEach(cycles) { cycle in
                                NavigationLink(destination: ReadingCycleDetailView(readingCycle: cycle)) {
                                    ReadingCycleComponent(readingCycle: cycle)
                                }
                                .swipeActions(edge: .leading){
                                    if cycle.active {
                                        Button {
                                            startReadingActivityForCycle(cycle)
                                        } label: {
                                            Label("read-now", systemImage: "book.fill")
                                        }
                                        .tint(.blue)
                                        Button {
                                            showCancelWarning = true
                                            selectedCycleToStop = cycle
                                        } label: {
                                            Label("Put Away", systemImage: "stop.circle.fill")
                                        }
                                        .tint(.red)
                                    } else {
                                        EmptyView()
                                    }
                                    
                                }
                            }
                        }
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    
                }
                .alert(isPresented: $activityStartedAlert) {
                    Alert(title: Text("Reading activity started!"))
                }
                .alert(isPresented: $hasActiveActivityAlert) {
                    Alert(title: Text("Active activity ongoing"), message: Text("already-active"))
                }
                .alert("Are you sure you want to put this book away?", isPresented: $showCancelWarning) {
                    Button("Yes") {
                        putBookAway(selectedCycleToStop!)
                    }
                    Button("No", role: .cancel) {}
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button("Dev: Delete all") {
                            dataController.deleteAll(entityName: "Genre")
                            dataController.deleteAll(entityName: "Book")
                            dataController.deleteAll(entityName: "Author")
                            dataController.deleteAll(entityName: "ReadingCycle")
                            dataController.deleteAll(entityName: "ReadingActivity")
                            dataController.deleteAll(entityName: "CoverLinks")
                        }
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSearchSheet = true
                    } label: {
                        Label("Add new book", systemImage: "magnifyingglass")
                    }
                    .sheet(isPresented: $showSearchSheet, onDismiss: {
                        titleAsString = selectedVolume.title ?? ""
                        navigateToNewCycleView = !titleAsString.isEmpty
                    }){
                        SearchView(selectedVolume: $selectedVolume, searchMode: $searchMode)
                    }
                    .sheet(isPresented: $navigateToNewCycleView, onDismiss: {
                        selectedVolume = VolumeInfo()
                    }) {
                        AddBookView(selectedVolume: $selectedVolume, titleAsString: $titleAsString, searchMode: $searchMode)
                    }
                }
            }
            .navigationTitle("read-now")
            
        }
    }
    
    func filterActivities() -> [ReadingActivity] {
        return activities.filter({$0.finishedAt == nil})
    }
    
    func filterCycles() -> [ReadingCycle] {
        return cycles.filter({$0.active})
    }
}
