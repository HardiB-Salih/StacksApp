//
//  MarketDataResponse.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import Foundation

struct MarketDataResponse: Codable {
    let open : [Double]
    let close : [Double]
    let high : [Double]
    let low : [Double]
    let status : String
    let timestamps : [TimeInterval]
    
    
    enum CodingKeys: String, CodingKey {
        case open  = "o"
        case close  = "c"
        case high   = "h"
        case low    = "l"
        case status  = "s"
        case timestamps  = "t"
    }
    
    var candleStick: [CandleStick] {
        var result = [CandleStick]()
        
        for index in 0..<open.count {
            result.append(
                .init(date: Date(timeIntervalSince1970: timestamps[index]),
                      open: open[index],
                      close: close[index],
                      high: high[index],
                      low: low[index]))
        }
        let sortedData = result.sorted(by: { $0.date > $1.date })
        return sortedData
    }
    
    
}

struct CandleStick {
    let date : Date
    let open : Double
    let close : Double
    let high : Double
    let low : Double
}



