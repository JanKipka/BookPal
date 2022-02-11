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
            MainView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear {
                    print("Documents Directory: ", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last ?? "Not Found!")
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .inactive:
                fallthrough
            case .background:
                print("### Saving ###")
                dataController.save()
            default:
                print("### App active ###")
            }
            
        }
    }
}
