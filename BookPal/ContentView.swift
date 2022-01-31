//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI
import Foundation
import CoreData

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: #keyPath(ReadingCycle.startedAt), ascending: true)
    ], predicate: NSPredicate(format: "active = true")) var cycles: FetchedResults<ReadingCycle>
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(key: #keyPath(ReadingActivity.startedAt), ascending: true)
    ], predicate: NSPredicate(format: "active = true")) var activities: FetchedResults<ReadingActivity>
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    
    @State var id: UUID = UUID()
    
    let apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    @State var navigateToNewCycleView: Bool = false
    @State var navigateToActivityView: Bool = false
    @State var activityStartedAlert: Bool = false
    @State var hasActiveActivityAlert: Bool = false
    @State var selectedActivity: ReadingActivity?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Colors.darkerBlue, Colors.lighterBlue]), startPoint: .top, endPoint: .bottom)
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
                            ForEach(cycles) { cycle in
                                NavigationLink(destination: ReadingCycleDetailView(readingCycle: cycle)) {
                                    ReadingCycleComponent(readingCycle: cycle)
                                }
                                .swipeActions(edge: .leading){
                                    Button {
                                        let hasActiveActivities = !activities.isEmpty
                                        if hasActiveActivities {
                                            hasActiveActivityAlert.toggle()
                                            return
                                        }
                                        let activity = ReadingActivity(context: moc)
                                        activity.active = true
                                        activity.startedAt = Date()
                                        activity.id = UUID()
                                        activity.readingCycle = cycle
                                        activity.startedActivityOnPage = cycle.currentPage
                                        dataController.save()
                                        activityStartedAlert.toggle()
                                    } label: {
                                        Label("Read Now", systemImage: "book.fill")
                                    }
                                    .tint(.blue)
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



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let dataController = DataController.preview
        
        MainView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
