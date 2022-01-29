//
//  DataController.swift
//  BookPal
//
//  Created by Jan Kipka on 28.01.22.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()
    
    let container: NSPersistentContainer
    
    let modelName = "Model"
    
    static var preview: DataController = {
        let controller = DataController(inMemory: true)
        return controller
    }()
    
    init(inMemory: Bool = false) {
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
