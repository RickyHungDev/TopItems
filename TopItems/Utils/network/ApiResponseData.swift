//
//  ApiResponseData.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import SwiftyJSON

struct ApiResponse {
    var data: AnyObject!
    
    var requestCacheExpiry: Int!
    var requestCached: Bool!
    var requestHash: String!
    
    var errors: ApiError!
}

class ApiError: NSObject {
    var status: Int!
    var type: String!
    var error: String!
    var message: String!
}

extension ApiResponse: JSONDecodable {
    init?(json: JSON) {
        if let jsonDictionary = json.dictionary {
            self.requestCacheExpiry = jsonDictionary["request_cache_expiry"]?.int ?? 0
            self.requestCached = jsonDictionary["request_cached"]?.bool ?? false
            self.requestHash = jsonDictionary["request_hash"]?.string ?? ""
            self.data = jsonDictionary["top"] as AnyObject
            
            if let _ = jsonDictionary["message"]?.string {
                let apiError = ApiError()
                apiError.status = jsonDictionary["status"]?.int ?? 0
                apiError.type = jsonDictionary["type"]?.string ?? ""
                apiError.error = jsonDictionary["error"]?.string ?? ""
                apiError.message = jsonDictionary["message"]?.string ?? ""
                self.errors = apiError
            }
        }
    }
}
