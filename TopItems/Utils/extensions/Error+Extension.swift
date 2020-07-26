//
//  Error+Extension.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import SwiftyJSON

enum APIClientError: Error {
    case CouldNotDecodeJSON
    case CouldNotRetrieveImage
    case RequestError(Error)
    
    //For HTTP status codes descriptions,
    // refer to https://docs.google.com/document/d/1N34CC4lJSBJ-v1CE0J2NJPKVUdQ_BE5nWRIo37W5hf0/edit
    case Unauthorized(ApiError)            //401 (Session Expired)
    case Forbidden(ApiError)               //403
    case ServiceUnavailable(ApiError)      //503 (Maintenance)
    case ApiError(ApiError)
}

extension APIClientError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .CouldNotDecodeJSON:
            return "Could not decode JSON"
        case .CouldNotRetrieveImage:
            return "No image retrieve image from response"
        case let .RequestError(error):
            return error.localizedDescription
        case let .Unauthorized(error):
            return "Unauthorized: " + error.type + ": " + error.error + ", " + error.message
        case let .Forbidden(error):
            return "Forbidden: " + error.type + ": " + error.error + ", " + error.message
        case let .ServiceUnavailable(error):
            return "Service Unavailable: " + error.type + ": " + error.error + ", " + error.message
        case let .ApiError(error):
            return "Api Error: " + error.type + ": " + error.error + ", " + error.message
        }
    }
    
    var status: String {
        switch self {
        case let .ApiError(error):
            return error.error
        default:
            return ""
        }
    }
}
