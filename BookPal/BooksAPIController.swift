//
//  BooksAPIController.swift
//  BookPal
//
//  Created by Jan Kipka on 29.01.22.
//

import Foundation

struct GoogleBooksAPIController {
    
    let volumePrefix = "https://www.googleapis.com/books/v1/volumes?q="
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "API Key") as? String
    let keyPrefix = "&key="
    let plus = "+"
    
    func queryForBooks(_ searchQuery: String, startIndex: Int = 0, maxResults: Int = 40, completion:@escaping ([Volume]) -> ()) async throws {
        guard let key = apiKey else {
            throw BookPalError.runtimeError("API Key not found, verify your configuration setup.")
        }
        
        guard let url = URL(string: buildURLString(query: searchQuery, key: key, startIndex: startIndex, maxResults: maxResults)) else {
            throw BookPalError.runtimeError("Invalid URL for accessing Google Books API")
        }
        print(url)
        URLSession.shared.dataTask(with: url) { data, response, error in
            let results = try! JSONDecoder().decode(VolumeResult.self, from: data!)
            DispatchQueue.main.async {
                completion(results.items)
            }
        }.resume()
    }
    
    private func buildURLString(query: String, key: String, startIndex: Int, maxResults: Int) -> String {
        return volumePrefix + convertToSearchString(inputString: query) + configurePagination(startIndex: startIndex, maxResults: maxResults) + keyPrefix + key
    }
    
    private func convertToSearchString(inputString: String) -> String {
        return inputString.split(separator: " ").joined(separator: plus)
    }
    
    private func configurePagination(startIndex: Int, maxResults: Int) -> String {
        return "&startIndex=\(startIndex)&maxResults=\(maxResults)"
    }
    
}

struct VolumeInfo: Codable {
    var title: String?
    var subtitle: String?
    var authors: [String]?
    var description: String?
    var pageCount: Int?
    var mainCategory: String?
    var imageLinks: ImageLinks?
    var categories: [String]?
}

struct ImageLinks: Codable {
    var thumbnail: String?
    var small: String?
    var medium: String?
    var large: String?
}

struct Volume: Codable, Identifiable {
    var id: String
    var volumeInfo: VolumeInfo
}

struct VolumeResult: Codable {
    var items: [Volume]
    var kind: String
}
