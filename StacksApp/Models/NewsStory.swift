//
//  NewsStory.swift
//  StacksApp
//
//  Created by HardiB.Salih on 5/5/24.
//

import Foundation

struct NewsStory : Codable{
    let category: String
    let datetime: TimeInterval
    let headline: String
    let id: Int
    let image: String
    let related:String
    let source:String
    let summary:String
    let url:String
}


//{
//  "category": "technology",
//  "datetime": 1596589501,
//  "headline": "Square surges after reporting 64% jump in revenue, more customers using Cash App",
//  "id": 5085164,
//  "image": "https://image.cnbcfm.com/api/v1/image/105569283-1542050972462rts25mct.jpg?v=1542051069",
//  "related": "",
//  "source": "CNBC",
//  "summary": "Shares of Square soared on Tuesday evening after posting better-than-expected quarterly results and strong growth in its consumer payments app.",
//  "url": "https://www.cnbc.com/2020/08/04/square-sq-earnings-q2-2020.html"
//},
