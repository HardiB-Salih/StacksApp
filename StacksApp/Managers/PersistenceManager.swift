//
//  PersistenceManager.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/4/24.
//

import Foundation
final class PersistenceManager {
    static let shared = PersistenceManager()
    
    
    private let userDefaults: UserDefaults = .standard
    private struct Constants {
        static let onboardedKey = "hasOnboarded"
        static let watchlistKey = "watchlist"

    }
    
    
    private init() {}
    
    //MARK: PUBLIC
    public var watchlist: [String] {
        if !hasOnboarded {
            userDefaults.set(true, forKey: Constants.onboardedKey)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Constants.watchlistKey) ?? []
    }
    
    public func addWatchList() {
        
    }
    
    public func removeWatchList() {
        
    }

    
    //MARK: PRIVATES
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey:  Constants.onboardedKey)
    }
    
    private func setUpDefaults() {
        let stockMap: [String: String] = [
            "AAPL": "Apple Inc.",
            "MSFT": "Microsoft Corporation",
            "SNAP": "Snap Inc.",
            "GOOG": "Alphabet Inc. (Google)",
            "AMZN": "Amazon.com Inc.",
            "WORK": "Slack Technologies Inc.",
            "FB": "Meta Platforms Inc. (Facebook)",
            "NVDA": "NVIDIA Corporation",
            "NKE": "Nike Inc.",
            "PINS": "Pinterest Inc.",
            "TSLA": "Tesla, Inc.",
            "NFLX": "Netflix, Inc.",
            "DIS": "The Walt Disney Company",
            "CRM": "Salesforce.com, Inc.",
            "PYPL": "PayPal Holdings, Inc.",
            "JPM": "JPMorgan Chase & Co.",
            "WMT": "Walmart Inc.",
            "V": "Visa Inc.",
            "BA": "The Boeing Company",
            "GM": "General Motors Company"
        ]
        
        let symbols = stockMap.keys.map { $0 }
        userDefaults.set(symbols, forKey: Constants.watchlistKey)
        
        for (symbol, name) in stockMap {
            userDefaults.set(name, forKey: symbol)
        }

    }
}
