//
//  ContentView.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI

struct ContentView: View {
    
    @FetchRequest(sortDescriptors: []) var genres: FetchedResults<Genre>
    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        VStack {
            List(genres) { genre in
                Text(genre.name ?? "Unknown")
            }
            Button("Add") {
                let firstNames = ["Horror", "Drama", "Comedy", "Romance", "Young Adult"]

                let chosenFirstName = firstNames.randomElement()!

                let genre = Genre(context: moc)
                genre.id = UUID()
                genre.name = chosenFirstName
                try? moc.save()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
        let dataController = DataController.preview
        
        ContentView()
            .environment(\.managedObjectContext, dataController.container.viewContext)
    }
}
