//
//  Result.swift
//  WeSplit
//
//  Created by sailesh sirari on 16/10/24.
//

import Foundation

struct Result1: Codable {
    let query: WikipediaQuery
    
}

struct WikipediaQuery: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    
    let pageid: Int
    let title: String
    let terms: [String: [String]]?
    static func <(lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    var description: String {
        terms?["description"]?.first ?? "No further information"
    }
}
