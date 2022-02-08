//
//  BooksController.swift
//  BookPal
//
//  Created by Jan Kipka on 02.02.22.
//

import Foundation
import CoreData

struct BooksController {
    
    let moc = DataController.shared.context
    
    let apiController = GoogleBooksAPIController()
    
    fileprivate func setGenre(_ category: String, book: Book) {
        if let genre = self.searchForGenreByString(category) {
            book.genre = genre
        } else {
            let genre = Genre(context: moc)
            genre.id = UUID()
            genre.name = category
            book.genre = genre
        }
    }
    
    func extractVolumeInformation(selectedVolume: VolumeInfo, book: Book, isbn: String, pageCount: Int?) {
        for author in selectedVolume.authors! {
            let names = author.split(separator: " ")
            if let aut = self.searchForPotentialAuthorMatch(firstName: String(names.first ?? ""), lastName: String(names.last ?? "")) {
                book.addToAuthors(aut)
            } else {
                let aut = Author(context: moc)
                aut.id = UUID()
                aut.firstName = names.dropLast().joined(separator: " ")
                aut.lastName = String(names.last ?? "")
                book.addToAuthors(aut)
            }
        }
        book.id = UUID()
        book.isbn = isbn
        book.dateAdded = Date.now
        book.title = selectedVolume.title!
        book.subtitle = selectedVolume.subtitle ?? ""
        book.publisher = selectedVolume.publisher ?? ""
        book.publishedDate = selectedVolume.publishedDate
        book.desc = selectedVolume.description ?? ""
        book.infoLink = selectedVolume.canonicalVolumeLink ?? selectedVolume.infoLink
        book.numOfPages = Int16(pageCount ?? selectedVolume.pageCount!)
        
        if let links = selectedVolume.imageLinks {
            let covers = CoverLinks(context: moc)
            covers.thumbnail = links.thumbnail
            covers.small = links.small
            covers.medium = links.medium
            covers.large = links.large
            book.coverLinks = covers
        }
        
        let genreString = selectedVolume.mainCategory ?? selectedVolume.categories?.first ?? ""
        setGenre(genreString, book: book)
        DataController.shared.save()
    }
    
    func createNewBookFromVolume(_ selectedVolume: VolumeInfo, searchMode: SearchMode, completion:@escaping (Book?) -> ()) {
        let isbn = selectedVolume.industryIdentifiers![0].identifier! // for now always use the first available isbn
        if searchMode == .isbn {
            Task {
                if let volume = await apiController.enrichVolumeWithCategoryInformation(title: selectedVolume.title!, authors: selectedVolume.authors!) {
                    let book = Book(context: moc)
                    extractVolumeInformation(selectedVolume: volume, book: book, isbn: isbn, pageCount: selectedVolume.pageCount)
                    completion(book)
                } else {
                    completion(nil)
                }
            }
        } else {
            let book = Book(context: moc)
            extractVolumeInformation(selectedVolume: selectedVolume, book: book, isbn: isbn, pageCount: selectedVolume.pageCount)
            completion(book)
        }
    }
    
    func getAllSavedBooks() -> [Book] {
        let fetchRequest: NSFetchRequest<Book> = Book.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        do {
            return try moc.fetch(fetchRequest)
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
            return try moc.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    func deleteBook(_ book: Book) {
        moc.delete(book)
        DataController.shared.save()
    }
    
    
}

extension BooksController {
    // Author Requests
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
            return try moc.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getAllSavedAuthors() -> [Author] {
        let fetchRequest: NSFetchRequest<Author> = Author.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        
        do {
            return try moc.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}

extension BooksController {
    // Genre Requests
    func searchForGenreByString(_ s: String) -> Genre? {
        let fetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "name = %@", s
        )
        do {
            return try moc.fetch(fetchRequest).first
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func getAllSavedGenres() -> [Genre] {
        let fetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try moc.fetch(fetchRequest)
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
}
