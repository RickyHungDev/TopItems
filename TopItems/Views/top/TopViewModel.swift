//
//  TopViewModel.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TopViewModel {
    private let disposeBag = DisposeBag()
    let isLoading: BehaviorRelay<Bool>
    let errorMessage: BehaviorRelay<String>
    let topData: BehaviorRelay<[TopDataModel]>
    private let topRemoteLoader: TopRemoteLoader!
    private let topServiceDone: BehaviorRelay<Bool>
    
    // MARK: LifeCycle
    init() {
        isLoading = BehaviorRelay(value: false)
        errorMessage = BehaviorRelay(value: "")
        topData = BehaviorRelay(value: [])
        topRemoteLoader = DefaultTopRemoteLoader(apiService: ApiManager.sharedApiManager)
//        topRemoteLoader = MockDefaultTopRemoteLoader()
        topServiceDone = BehaviorRelay(value: false)
    }
    
    // MARK: Private
    
    // MARK: Public
    func load() {
        
    }
    
    func loadTopDetail(topType: TopTypes, topSubtypeIndex: Int?, page: Int?) {
        self.isLoading.accept(true)
        var subtype: String?
        if let topSubtypeIndex = topSubtypeIndex {
            if topType == .Anime {
                subtype = AnimeSubtype(id: topSubtypeIndex)?.rawValue.lowercased()
            } else if topType == .Manga {
                subtype = MangaSubtype(id: topSubtypeIndex)?.rawValue.lowercased()
            }
        }
        
        topRemoteLoader.load(type: topType, subType: subtype, page: page).asObservable().subscribe(onNext: { [unowned self] (dataModel) in
            self.topServiceDone.accept(true)
            self.topData.accept(dataModel)
            self.isLoading.accept(false)
        }, onError: { [unowned self] (error) in
            self.topServiceDone.accept(true)
            let apiError = error as! APIClientError
            self.errorMessage.accept(apiError.debugDescription)
            self.isLoading.accept(false)
            }).disposed(by: disposeBag)
    }
}
