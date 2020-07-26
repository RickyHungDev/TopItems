//
//  Request.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import SwiftyJSON

@objc public enum RequestMethod: Int, RawRepresentable {
    case GET
    case POST
    case DELETE
    case PUT
    
    public typealias RawValue = String
    
    public var rawValue: RawValue {
        switch self {
        case .GET:
            return "GET"
        case .POST:
            return "POST"
        case .DELETE:
            return "DELETE"
        case .PUT:
            return "PUT"
        }
    }
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        case "GET":
            self = .GET
        case "POST":
            self = .POST
        case "DELETE":
            self = .DELETE
        case "PUT":
            self = .PUT
        default:
            self = .GET
        }
    }
}

enum RequestResult {
    case success(JSON)
    case parsed(AnyObject)
    case failure(Error)
}

@objc protocol Request {
    var path: String { get }
    var method: RequestMethod { get }
    @objc optional var parameters: [String: AnyObject]! { get }
    @objc optional var additionalHeaders: [String: String]! { get }
}

extension Request {
    func getRequest(isDirectory: Bool? = true) -> URLRequest {
        var url = ApiManager.baseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let parameters = parameters {
            switch method {
            case .GET, .DELETE:
                var pathContinuation = "?"
                guard parameters != nil else {
                    let urlString = request.url?.absoluteString
                    let decodedUrl = NSURL(string: (urlString?.replacingOccurrences(of: "%3F", with: "?"))!)
                    request.url = decodedUrl! as URL
                    return request
                }
                for (index, key) in parameters!.keys.enumerated() {
                    pathContinuation += key + "=" + "\(parameters![key]!)"
                    
                    if index < parameters!.keys.count - 1 {
                        pathContinuation += "&"
                    }
                }
                
                url = url.appendingPathComponent(pathContinuation)
                
                if !isDirectory! {
                    if let urlString = URL(string: url.absoluteString.replacingOccurrences(of: "/qrcode/", with: "/qrcode").replacingOccurrences(of: "%3F", with: "?")) {
                        url = urlString
                    }
                }
                
                request.url = url
                
            default:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters!, options: .prettyPrinted)
                } catch let error as NSError {
                    fatalError("Error conversion to JSON: \(error)")
                }
            }
        }
        
        if let additionalHeaders = additionalHeaders as? [String: String] {
            for key in additionalHeaders.keys {
                request.addValue(additionalHeaders[key]!, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}
