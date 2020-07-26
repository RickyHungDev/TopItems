//
//  UIImageView+Extension.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import RxSwift

extension UIImageView {
    static var disposeBag = DisposeBag()
    
    func loadImageFromCache(withImageUrl imageUrl: String!) {
        guard let imageUrl = imageUrl, imageUrl != "" else { return }
        let imageDownloadService = ImadeDownloadAlamofireService()
        imageDownloadService.path = imageUrl.replacingOccurrences(of: "http:", with: "https:")
        print("url " + imageUrl)
        ApiManager.sharedApiManager.performWithoutBaseUrlWithImageReponse(request: imageDownloadService).subscribe(onNext: {[unowned self] (image) in
            self.image = image
            }, onError: { (error) in
                print("url " + imageUrl)
                self.image = nil
        }).disposed(by: UIImageView.disposeBag)
    }
}
