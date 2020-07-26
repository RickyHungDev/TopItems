//
//  WebViewModel.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class WebViewModel {
    let isLoading: BehaviorRelay<Bool>
    let errorMessage: BehaviorRelay<String>
    private let disposeBag = DisposeBag()
    
    // MARK: LifeCycle
    init() {
        isLoading = BehaviorRelay(value: false)
        errorMessage = BehaviorRelay(value: "")
    }
    
    deinit {
        print("\ndeinit \(self)")
    }
    
    // MARK: Private
    private func loginSuccess() {
        isLoading.accept(false)
    }
    
    // MARK: Public
}
