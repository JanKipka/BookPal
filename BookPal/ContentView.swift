//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "active = true")) var cycles: FetchedResults<ReadingCycle>
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "active = true")) var activities: FetchedResults<ReadingActivity>
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    
    @State var id: UUID = UUID()
    
    let apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    @State var navigateToNewCycleView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    VStack {
                        Text("Active reading activities").font(.headline)
                        List {
                            ForEach(activities) { ac in
                                ReadingActivityComponent(readingActivity: ac)
                            }
                        }
                    }
                }
                .background(.regularMaterial)
                .frame(height: 350)
                ZStack {
                    VStack {
                        Text("Books you're reading").font(.headline)
                        List {
                            ForEach(cycles) { cycle in
                                ReadingCycleComponent(readingCycle: cycle)
                            }
                        }
                    }
                }
                .background(.regularMaterial)
                .frame(height: 350)
                
                NavigationLink(destination: NewReadingCycleView()) {
                    Text("Start a new book")
                }
                
                
                Button("Delete All") {
                    dataController.deleteAll(entityName: "Genre")
                    dataController.deleteAll(entityName: "Book")
                    dataController.deleteAll(entityName: "Author")
                    dataController.deleteAll(entityName: "ReadingCycle")
                    dataController.deleteAll(entityName: "ReadingActivity")
                }
                Spacer()
            }
        }
//        .task {
//            activeCycles = filterCycles()
//            for cycle in activeCycles {
//                mapCyclesActivities(cycle: cycle)
//            }
//            activeActivities = filterActivities()
//            hasActiveCycles = !activeCycles.isEmpty
//        }
        .navigationBarTitle("Your Reading Activity")
        .navigationBarHidden(true)
        .id(id)
        .refreshable {
            id = UUID()
        }
    }
    
//    func mapCyclesActivities(cycle: ReadingCycle) {
//        let activities = dataController.getActiveReadingActivitiesForCycle(cycle)
//        cyclesActivities[cycle] = []
//        for ac in activities {
//            cyclesActivities[cycle]?.append(ac)
//        }
//    }
    
    func getActiveActivitesForCycle(_ cycle: ReadingCycle) -> [ReadingActivity] {
        dataController.getActiveReadingActivitiesForCycle(cycle)
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
        
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
