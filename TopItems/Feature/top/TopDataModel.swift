//
//  TopDataModel.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation

struct RequestObjectDataModel: Codable {
    var requestCacheExpiry: Int!
    var requestCached: Bool!
    var requestHash: String!
    var top: [TopDataModel]!
    
    enum CodingKeys: String, CodingKey {
        case requestCacheExpiry = "request_cache_expiry"
        case requestCached = "request_cached"
        case requestHash = "request_hash"
        case top
    }
}

struct TopDataModel: Codable, Equatable {
    var endDate: String!
    var episodes: Int!
    var imageUrl: String!
    var malId: Int!
    var members: Int!
    var rank: Int!
    var score: Double!
    var startDate: String!
    var title: String!
    var type: String!
    var url: String!
    
    enum CodingKeys: String, CodingKey {
        case endDate = "end_date"
        case episodes
        case imageUrl = "image_url"
        case malId = "mal_id"
        case members
        case rank
        case score
        case startDate = "start_date"
        case title
        case type
        case url
    }
}

