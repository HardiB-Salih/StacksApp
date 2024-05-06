//
//  ApiCaller.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/4/24.
//

import Foundation

final class ApiCaller {
    static let shared = ApiCaller()
    
    private struct Constants {
        static let apiKey = "coraov1r01qm70u0ot00coraov1r01qm70u0ot0g"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let day: TimeInterval = 3600 * 24
        static let polygonApiKey = "1RXnE1rAKsEgvhLdH9amNp7RDqEYj5yg"
        
        

    }
    
    private init() {}
    //MARK: Publick
    
    public func search(
        query: String,
        complition: @escaping(Result<SearchResponse, Error> ) -> Void
    ) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let url = url(for: .search, queryParams: ["q" : safeQuery]) else { return }
        request(
            url: url,
            expecting: SearchResponse.self,
            completion: complition)
    }
    
    public func news(
        for type: NewsViewController.`Type`,
        complition: @escaping(Result<[NewsStory], Error> ) -> Void
    ){
        switch type {
        case .topStories:
            request(
                url: url(for: .topStories, queryParams: ["category" : "general"]),
                expecting: [NewsStory].self,
                completion: complition)
        case.company(let symbol):
            let today = Date()
            let oneMonthBack = today.addingTimeInterval(-(Constants.day * 30))
            request(
                url: url(
                    for: .companyNews,
                    queryParams: [
                        "symbol" : symbol,
                        "from":DateFormatter.newsDateFormatter.string(from: oneMonthBack),
                        "to":DateFormatter.newsDateFormatter.string(from: today),
                    ]),
                expecting: [NewsStory].self,
                completion: complition)
        }
    }
    
    
//    public func marketData(
//        for symbol: String,
//        nuberOfDays: TimeInterval = 7,
//        complition: @escaping(Result<MarketDataResponse, Error> ) -> Void
//    ){
//        let today = Date().addingTimeInterval(-(Constants.day))
//        let prior = today.addingTimeInterval(-(Constants.day * nuberOfDays))
//        
//        // Convert dates to time intervals
//        let fromTimeInterval = Int(prior.timeIntervalSince1970)
//        let toTimeInterval = Int(today.timeIntervalSince1970)
//        
//        request(
//            url: url(
//                for: .marketData,
//                queryParams: [
//                    "symbol" : symbol,
//                    "resolution": "1",
//                    "from": "\(fromTimeInterval)",
//                    "to": "\(toTimeInterval)",
//                ]),
//            expecting: MarketDataResponse.self,
//            completion: complition)
//    }
    

    public func marketData(
        for symbol: String,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void
    ) {
        // Load local JSON file
        guard let url = Bundle.main.url(forResource: "marketData", withExtension: "json") else {
            completion(.failure(NSError(domain: "FileNotFound", code: 0, userInfo: nil)))
            return
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
            
            // Check if the JSON contains data for the requested symbol
            guard let symbolData = json?[symbol] as? [String: Any] else {
                completion(.failure(NSError(domain: "SymbolNotFound", code: 0, userInfo: nil)))
                return
            }
            
            // Convert symbolData back to JSON data
            let symbolJsonData = try JSONSerialization.data(withJSONObject: symbolData, options: [])
            
            // Decode JSON data into MarketDataResponse
            let marketData = try JSONDecoder().decode(MarketDataResponse.self, from: symbolJsonData)
            completion(.success(marketData))
        } catch {
            completion(.failure(error))
        }
    }

    
    public func financialMatrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMatricsResponse, Error>) -> Void
    ) {
        request(
            url:
                url(
                    for: .financials,
                    queryParams: ["symbol" : symbol, "metric" : "all"]),
            expecting: FinancialMatricsResponse.self,
            completion: completion )
    }


    
    // MARK: - Private
    private enum Endpoint: String {
        case search
        case topStories = "news"
        case companyNews = "company-news"
        case marketData = "stock/candle"
        case financials = "stock/metric"
    }
    
    private enum APIError: Error {
        case noDataReturned
        case invalidUrl
    }
    
    private func url(
        for endpoint: Endpoint,
        queryParams: [String: String] = [:]) -> URL? {
            
            var urlString = Constants.baseUrl + endpoint.rawValue
            var queryItem = [URLQueryItem]()

            //Add any Prameter
            
            for(name, value) in queryParams {
                queryItem.append(.init(name: name, value: value))
            }
            
            // Add Token
            queryItem.append(.init(name: "token", value: Constants.apiKey))
            
            // Convert query item to suffix string
            urlString += "?" + queryItem.map { "\($0.name)=\($0.value ?? "")"}.joined(separator: "&")
//            print(urlString)
            return URL(string: urlString)
    }
    
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping (Result<T, Error>) -> Void) {
        
            guard let url = url else {
                //Invalid url
                completion(.failure(APIError.invalidUrl))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(APIError.noDataReturned))
                    }
                    return
                }
                
                do{
                    let result = try JSONDecoder().decode(expecting, from: data)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }
            }
            
            task.resume()
    }
}
