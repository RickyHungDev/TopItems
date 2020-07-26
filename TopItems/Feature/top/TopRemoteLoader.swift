//
//  TopRemoteLoader.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift

protocol TopRemoteLoader{
    func load(type: TopTypes, subType: String?, page: Int?) -> Observable<[TopDataModel]>
}
