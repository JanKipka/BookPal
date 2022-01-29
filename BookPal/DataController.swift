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
    
    let modelName = "Model"
    
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
        container = NSPersistentContainer(name: modelName)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            
            self.container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        }
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteAll(entityName name: String) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: name)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            save()
            try container.viewContext.execute(deleteRequest)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}
