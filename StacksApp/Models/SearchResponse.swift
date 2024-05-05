//
//  SearchResponse.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import Foundation

struct SearchResponse : Codable {
    let count : Int
    let result: [SearchResult]
}

struct SearchResult: Codable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String
}


