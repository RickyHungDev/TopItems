//
//  JsonDataParser.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON

public class JsonDataParser {
    func parse<T: Codable>(json: JSON) -> Observable<T> {
        if let apiResponse = ApiResponse(json: json) {
            if let json = apiResponse.data as? JSON {
                let jsonDecoder = JSONDecoder()
                do {
                    let data = try jsonDecoder.decode(T.self, from: json.rawData())
                    return Observable.just(data)
                } catch _ {
                    return Observable.error(APIClientError.CouldNotDecodeJSON)
                }
            }
        }
        
        return Observable.error(APIClientError.CouldNotDecodeJSON)
    }
}
