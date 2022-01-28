//
//  DataController.swift
//  BookPal
//
//  Created by Jan Kipka on 28.01.22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    // A singleton for our entire app to use
    static let shared = DataController()
    
    // Storage for Core Data
    let container: NSPersistentContainer
    
    // A test configuration for SwiftUI previews
    static var preview: DataController = {
        let controller = DataController(inMemory: true)
        
        // Create 10 example programming languages.
        for _ in 0..<10 {
            let genre = Genre(context: controller.container.viewContext)
            genre.name = "Drama"
        }
        
        return controller
    }()
    
    // An initializer to load Core Data, optionally able
    // to use an in-memory store.
    init(inMemory: Bool = false) {
        // If you didn't name your model Main you'll need
        // to change this name below.
        container = NSPersistentContainer(name: "Model")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
