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
    
    fileprivate func startReadingActivityForCycle(_ cycle: ReadingCycle) {
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
                Colors.linearGradient(topColor: Colors.darkerBlue, bottomColor: Colors.lighterBlue)
                    .ignoresSafeArea()
                VStack {
                    NavigationLink(destination: NewReadingCycleView(), isActive: $navigateToNewCycleView) {
                        EmptyView()
                    }
                    List {
                        Section("Active reading activities") {
                            ForEach(activities) { ac in
                                NavigationLink(destination: ReadingActivityDetailView(readingActivity: ac)) {
                                    ReadingActivityComponent(readingActivity: ac)
                                }
                            }
                        }
                        
                        Section("Books you're reading") {
                            ForEach(cycles.sorted(by: {$0.lastUpdated > $1.lastUpdated})) { cycle in
                                NavigationLink(destination: ReadingCycleDetailView(readingCycle: cycle)) {
                                    ReadingCycleComponent(readingCycle: cycle)
                                }
                                .swipeActions(edge: .leading){
                                    if cycle.active {
                                        Button {
                                            startReadingActivityForCycle(cycle)
                                        } label: {
                                            Label("Read Now", systemImage: "book.fill")
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
                    Alert(title: Text("Active activity ongoing"), message: Text("There's already an active reading acitivity."))
                }
                .alert("Are you sure you want to put this book away?", isPresented: $showCancelWarning) {
                    Button("Yes") {
                        putBookAway(selectedCycleToStop!)
                    }
                    Button("No", role: .cancel) {}
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add a new book") {
                            navigateToNewCycleView = true
                        }
                        Button("Dev: Delete all") {
                            dataController.deleteAll(entityName: "Genre")
                            dataController.deleteAll(entityName: "Book")
                            dataController.deleteAll(entityName: "Author")
                            dataController.deleteAll(entityName: "ReadingCycle")
                            dataController.deleteAll(entityName: "ReadingActivity")
                            dataController.deleteAll(entityName: "CoverLinks")
                        }
                    } label: {
                        Label("Add new book", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("Read now")
            
        }
    }
    
    func filterActivities() -> [ReadingActivity] {
        return activities.filter({$0.finishedAt == nil})
    }
    
    func filterCycles() -> [ReadingCycle] {
        return cycles.filter({$0.active})
    }
}



//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//
//        let dataController = DataController.preview
//
//        MainView()
//            .environment(\.managedObjectContext, dataController.container.viewContext)
//    }
//}
