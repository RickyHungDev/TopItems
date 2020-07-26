//
//  DefaultTopRemoteLoader.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift

class DefaultTopRemoteLoader: TopRemoteLoader {
    var apiService:ApiManager
    var parser: JsonDataParser
    
    init(apiService: ApiManager) {
        self.apiService = apiService
        self.parser = JsonDataParser()
    }
    
    func load(type: TopTypes, subType: String?, page: Int?) -> Observable<[TopDataModel]> {
        return self.apiService
            .perform(request: TopAlamofireService().load(type: type, subType: subType, page: page))
            .flatMap(parser.parse)
    }
}
