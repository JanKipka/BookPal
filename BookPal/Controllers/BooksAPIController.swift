//
//  BooksAPIController.swift
//  BookPal
//
//  Created by Jan Kipka on 29.01.22.
//

import Foundation
import SwiftUI

protocol IGoogleBooksAPIController {
    mutating func queryForBooks(_ searchQuery: String, startIndex: Int, maxResults: Int, searchMode: SearchMode, completion:@escaping ([Volume]) -> ()) async throws
}

struct GoogleBooksAPIController: IGoogleBooksAPIController {
    
    let volumePrefix = "https://www.googleapis.com/books/v1/volumes?q="
    let plus = "+"
    var prevSearchQuery = ""
    var prevSearchMode: SearchMode?
    
    mutating func queryForBooks(_ searchQuery: String, startIndex: Int = 0, maxResults: Int = 40, searchMode: SearchMode = .query, completion:@escaping ([Volume]) -> ()) throws {
        if (searchQuery.isEmpty) {
            completion([])
        }
        
        if (prevSearchMode == searchMode && prevSearchQuery == searchQuery) {
            return
        }
        
        prevSearchMode = searchMode
        prevSearchQuery = searchQuery
        
        guard let url = URL(string: buildURLString(query: searchQuery, startIndex: startIndex, maxResults: maxResults, searchMode: searchMode)) else {
            throw BookPalError.runtimeError("Invalid URL for accessing Google Books API")
        }
#if DEBUG
        print(url)
#endif
        URLSession.shared.dataTask(with: url) { data, response, error in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)
            if let theData = data {
                if let results = try? decoder.decode(VolumeResult.self, from: theData) {
                    DispatchQueue.main.async {
                        completion(results.items)
                    }
                } else {
                    completion([])
                }
            }
        }.resume()
    }
    
    func enrichVolumeWithCategoryInformation(title: String, authors: [String]) async -> VolumeInfo? {
        do {
            let urlString = volumePrefix + "intitle:\(convertToSearchString(inputString: title))+inauthor:\(convertAuthorToSearchString(authors.first ?? ""))" + "&filter=ebooks"
#if DEBUG
            print(urlString)
#endif
            guard let url = URL(string: urlString) else {
                throw BookPalError.runtimeError("Invalid URL for accessing Google Books API")
            }
            let (data, _) = try await URLSession.shared.data(from: url)
            if let results = try? JSONDecoder().decode(VolumeResult.self, from: data) {
                let foundVolume = results.items.map({$0.volumeInfo})
                    .filter({$0.categories != nil})
                    .filter({$0.pageCount != nil})
                    .first ?? nil
                return foundVolume
            } else {
                return nil
            }
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        
    }
    
    private func convertAuthorToSearchString(_ author: String) -> String {
        return author.split(separator: " ").joined(separator: "%20")
    }
    
    private func buildURLString(query: String, startIndex: Int, maxResults: Int, searchMode: SearchMode) -> String {
        let searchBase = searchMode == .isbn ? volumePrefix + "isbn:" + query : volumePrefix + convertToSearchString(inputString: query)
        return searchBase + configurePagination(startIndex: startIndex, maxResults: maxResults)
    }
    
    private func convertToSearchString(inputString: String) -> String {
        return inputString.split(separator: " ").joined(separator: plus)
    }
    
    private func configurePagination(startIndex: Int, maxResults: Int) -> String {
        return "&startIndex=\(startIndex)&maxResults=\(maxResults)"
    }
    
}

enum SearchMode: String, Equatable, CaseIterable {
    case query = "query"
    case isbn = "isbn"
    
    var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
}


struct VolumeInfo: Codable, Hashable {
    static func == (lhs: VolumeInfo, rhs: VolumeInfo) -> Bool {
        return lhs.title == rhs.title && lhs.authors == rhs.authors && lhs.industryIdentifiers == lhs.industryIdentifiers
    }
    
    init() {
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try? container.decode(String.self, forKey: .title)
        subtitle = try? container.decode(String.self, forKey: .subtitle)
        authors = try? container.decode(Array.self, forKey: .authors)
        description = try? container.decode(String.self, forKey: .description)
        pageCount = try? container.decode(Int.self, forKey: .pageCount)
        mainCategory = try? container.decode(String.self, forKey: .mainCategory)
        imageLinks = try? container.decode(ImageLinks.self, forKey: .imageLinks)
        categories = try? container.decode(Array.self, forKey: .categories)
        industryIdentifiers = try? container.decode(Array.self, forKey: .industryIdentifiers)
        canonicalVolumeLink = try? container.decode(String.self, forKey: .canonicalVolumeLink)
        infoLink = try? container.decode(String.self, forKey: .infoLink)
        publisher = try? container.decode(String.self, forKey: .publisher)
        publishedDate = try? container.decode(Date.self, forKey: .publishedDate)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(pageCount)
        hasher.combine(industryIdentifiers)
        hasher.combine(authors)
    }
    
    var title: String?
    var subtitle: String?
    var authors: [String]?
    var description: String?
    var pageCount: Int?
    var mainCategory: String?
    var imageLinks: ImageLinks?
    var categories: [String]?
    var industryIdentifiers: [IndustryIdentifier]?
    var canonicalVolumeLink: String?
    var infoLink: String?
    var publisher: String?
    var publishedDate: Date?
}

struct ImageLinks: Codable {
    var thumbnail: String?
    var small: String?
    var medium: String?
    var large: String?
}

struct IndustryIdentifier: Codable, Hashable {
    var type: String?
    var identifier: String?
}

struct Volume: Codable, Identifiable {
    var id: String
    var volumeInfo: VolumeInfo
}

struct VolumeResult: Codable {
    var items: [Volume]
    var kind: String
}
