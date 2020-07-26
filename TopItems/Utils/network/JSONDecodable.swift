//
//  JSONDecodable.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

protocol JSONDecodable {
    init?(json: JSON)
}

func decode<T: JSONDecodable>(json: JSON) -> T? {
    return T(json: json)
}

func decodeObjects<T: JSONDecodable>(json: Observable<JSON>) -> Observable<T> {
    return json.map { json in
        guard let object: T = decode(json: json) else {
            throw APIClientError.CouldNotDecodeJSON
        }
        
        return object
    }
}
