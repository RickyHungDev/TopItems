//
//  TopAlamofireService.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import Foundation

public class TopAlamofireService:Request {
    var path = "top/"
    var method = RequestMethod.GET
    let basePath = "top/"
    
    func load(type: TopTypes, subType: String?, page: Int?) -> Request {
        self.path = self.basePath + type.rawValue.lowercased()
        if let page = page {
            self.path = self.path + "/\(page)"
        }
        if let subType = subType {
            self.path = self.path + "/\(subType.lowercased())"
        }
        return self
    }
}
