//
//  BookPalApp.swift
//  BookPal
//
//  Created by Jan Kipka on 27.01.22.
//

import SwiftUI

@main
struct BookPalApp: App {
    
    let dataController = DataController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            dataController.save()
        }
    }
}
