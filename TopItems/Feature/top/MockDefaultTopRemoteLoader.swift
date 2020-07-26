//
//  MockDefaultTopRemoteLoader.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift

class MockDefaultTopRemoteLoader: TopRemoteLoader {
    func load(type: TopTypes, subType: String?, page: Int?) -> Observable<[TopDataModel]> {
        var dataModel: [TopDataModel] = []
        
        for index in 0...5 {
            let malId = 5114
            let title = "Fullmetal Alchemist: Brotherhood"
            let rank = index
            let startDate = "Apr 2009"
            let endDate = "Jul 2010"
            let type = "TV"
            let episodes = 64
            let score = 9.23
            let members = 1844434
            let url = "https://myanimelist.net/anime/5114/Fullmetal_Alchemist__Brotherhood"
            let imageUrl = "https://cdn.myanimelist.net/images/anime/1223/96541.jpg?s=faffcb677a5eacd17bf761edd78bfb3f"
            let data = TopDataModel(endDate: endDate, episodes: episodes, imageUrl: imageUrl, malId: malId, members: members, rank: rank, score: score, startDate: startDate, title: title, type: type, url: url)
            dataModel.append(data)
        }
        
        return Observable.just(dataModel)
    }
}
