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
    
    let context: NSManagedObjectContext
    
    static var preview: DataController = {
        let controller = DataController(inMemory: true)
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: modelName)
        context = container.viewContext
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
            try container.viewContext.execute(deleteRequest)
            save()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
}

extension DataController {
    
    func getAllSavedBooks() -> [Book] {
        // Create a fetch request for a specific Entity type
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        
        // Fetch all objects of one Entity type
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getBookByISBN(_ isbn: String) -> Book? {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "isbn = %@", isbn
        )
        do {
            return try context.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
}

extension DataController {
    
    func searchForPotentialAuthorMatch(firstName: String, lastName: String) -> Author? {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest();
        let firstNamePredicate = NSPredicate(format: "firstName BEGINSWITH %@", firstName)
        let lastNamePredicate = NSPredicate(format: "lastName BEGINSWITH %@", lastName)
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                firstNamePredicate,
                lastNamePredicate
            ]
        )
        do {
            return try context.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
}

extension DataController {
    
    func searchForGenreByString(_ s: String) -> Genre? {
        let fetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "name = %@", s
        )
        do {
            return try context.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
}

extension DataController {
    
    func getActiveReadingActivities() -> [ReadingActivity] {
        let fetchRequest: NSFetchRequest<ReadingActivity> = ReadingActivity.fetchRequest()
        let endDateNotSetPred = NSPredicate(format: "ANY finishedAt = nil")
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                endDateNotSetPred
            ]
        )
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    func getActiveReadingCycles() -> [ReadingCycle] {
        let fetchRequest: NSFetchRequest<ReadingCycle> = ReadingCycle.fetchRequest()
        let endDateNotSetPred = NSPredicate(format: "active = true")
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                endDateNotSetPred
            ]
        )
        do {
            return try context.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}
