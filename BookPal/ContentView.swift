//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: []) var cycles: FetchedResults<ReadingCycle>
    @Environment(\.managedObjectContext) var moc
    
    let dataController = DataController.shared
    
    let apiController: GoogleBooksAPIController = GoogleBooksAPIController()
    
    @State var activeCycles: [ReadingCycle] = []
    @State var hasActiveCycles: Bool = false
    @State var navigateToNewCycleView: Bool = false
    
    var body: some View {
        NavigationView {
            if !self.$hasActiveCycles.wrappedValue {
                NavigationLink(destination: NewReadingCycleView()) {
                    Text("Start a new book")
                }
            } else {
                Text("You're currently reading \(activeCycles.count) books")
            }
            
            Button("Delete All") {
                dataController.deleteAll(entityName: "Genre")
                dataController.deleteAll(entityName: "Book")
                dataController.deleteAll(entityName: "ReadingCycle")
            }
        }.navigationTitle("BookPal").onAppear() {
            activeCycles = filterCycles()
            hasActiveCycles = !activeCycles.isEmpty
        }
//        .task {
//            do {
//                try await apiController.queryForBooks("Harry Potter") { (results) in
//                    print(results!)
//                }
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        }
    }
    
    func filterCycles() -> [ReadingCycle] {
        return cycles.filter({$0.active})
    }
    
    func formatDate(_ d: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: d)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let dataController = DataController.preview
        
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
