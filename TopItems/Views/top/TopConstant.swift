//
//  TopConstant.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit

struct TopConsts {
    static let COLLECTIONVIEW_CELL_ROW_HEIGHT: CGFloat = 50
    static let TABLEVIEW_CELL_ROW_HEIGHT: CGFloat = 180
}

enum TopTypes: String, CaseIterable {
    case Anime
    case Manga
    case People
    case Characters
    case Favorite
    
    init?(id: Int) {
        switch id {
        case 0: self = .Anime
        case 1: self = .Manga
        case 2: self = .People
        case 3: self = .Characters
        case 4: self = .Favorite
        default: return nil
        }
    }
}

enum AnimeSubtype: String, CaseIterable {
    case Airing
    case Upcoming
    case TV
    case Movie
    case OVA
    case Special
    case ByPopularity
    case Favorite
    
    init?(id: Int) {
        switch id {
        case 0: self = .Airing
        case 1: self = .Upcoming
        case 2: self = .TV
        case 3: self = .Movie
        case 4: self = .OVA
        case 5: self = .Special
        case 6: self = .ByPopularity
        case 7: self = .Favorite
        default: return nil
        }
    }
}

enum MangaSubtype: String, CaseIterable {
    case Manga
    case Novels
    case Oneshots
    case Doujin
    case Manhwa
    case Manhua
    case ByPopularity
    case Favorite
    
    init?(id: Int) {
        switch id {
        case 0: self = .Manga
        case 1: self = .Novels
        case 2: self = .Oneshots
        case 3: self = .Doujin
        case 4: self = .Manhwa
        case 5: self = .Manhua
        case 6: self = .ByPopularity
        case 7: self = .Favorite
        default: return nil
        }
    }
}

enum TopCollectionCells {
    case Item
    
    var nibName: String {
        switch self {
        case .Item: return "ItemCollectionViewCell"
        }
    }
    
    var identifier: String {
        switch self {
        case .Item: return "item_cell"
        }
    }
    
    static let allCellType: [TopCollectionCells] = [.Item]
    
}

enum TopTableViewCells {
    case Item
    
    var nibName: String {
        switch self {
        case .Item: return "ItemTableViewCell"
        }
    }
    
    var identifier: String {
        switch self {
        case .Item: return "item_cell"
        }
    }
    
    static let allCellType: [TopTableViewCells] = [.Item]
    
}
