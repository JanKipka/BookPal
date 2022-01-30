//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: []) var cycles: FetchedResults<ReadingCycle>
    @FetchRequest(sortDescriptors: []) var activities: FetchedResults<ReadingActivity>
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    
    let apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    
    @State var activeCycles: [ReadingCycle] = []
    @State var activeActivities: [ReadingActivity] = []
    @State var hasActiveCycles: Bool = false
    @State var navigateToNewCycleView: Bool = false
    @State var cyclesActivities = [ReadingCycle: [ReadingActivity]]()
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    VStack {
                        Text("Currently reading").font(.title2)
                        List {
                            ForEach(Array(cyclesActivities.keys)) { cycle in
                                ReadingCycleComponent(readingCycle: cycle, numOfActiveActivities: cyclesActivities[cycle]?.count)
                            }
                        }
                    }
                }
                .background(.regularMaterial)
                .frame(height: 500)
                
                NavigationLink(destination: NewReadingCycleView()) {
                    Text("Start a new book")
                }
                
                
                Button("Delete All") {
                    dataController.deleteAll(entityName: "Genre")
                    dataController.deleteAll(entityName: "Book")
                    dataController.deleteAll(entityName: "ReadingCycle")
                }
                Spacer()
            }
        }.task {
            activeCycles = filterCycles()
            for cycle in activeCycles {
                mapCyclesActivities(cycle: cycle)
            }
            activeActivities = filterActivities()
            hasActiveCycles = !activeCycles.isEmpty
        }
        .navigationBarHidden(true)
    }
    
    func mapCyclesActivities(cycle: ReadingCycle) {
        let activities = dataController.getActiveReadingActivitiesForCycle(cycle)
        cyclesActivities[cycle] = []
        for ac in activities {
            cyclesActivities[cycle]?.append(ac)
        }
    }
    
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
