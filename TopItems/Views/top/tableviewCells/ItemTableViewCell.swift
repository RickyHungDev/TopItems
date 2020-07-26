//
//  ItemTableViewCell.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var cellModel: TopDataModel!
    
    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: Private
    private func setupViews() {
        favoriteButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        favoriteButton.setImage(UIImage(named: "heart-outline")?.maskWithColor(color: UIColor.red, size: CGSize(width: 30, height: 30)), for: .selected)
        favoriteButton.addTarget(self, action: #selector(didTapFavoriteButton(_:)), for: .touchUpInside)
    }
    
    @objc private func didTapFavoriteButton(_ sender: UIButton) {
        
        if let favoriteData = UserDefaults.standard.object(forKey: "favorites") as? Data {
            var favorites: [TopDataModel] = []
            let decoder = JSONDecoder()
            if let savedTop = try? decoder.decode([TopDataModel].self, from: favoriteData) {
                print(savedTop)
                favorites = savedTop
            }
            
            var newFavorites: [TopDataModel]
            if favorites.contains(cellModel) {
                newFavorites = favorites.filter {$0 != cellModel}
                favoriteButton.isSelected = false
            } else {
                newFavorites = favorites
                newFavorites.append(cellModel)
                favoriteButton.isSelected = true
            }
            
            let encoder = JSONEncoder()
            if let encoderModel = try? encoder.encode(newFavorites) {
                UserDefaults.standard.set(encoderModel, forKey: "favorites")
            }
        } else {
            let newFavorites = [cellModel!]
            favoriteButton.isSelected = true
            
            let encoder = JSONEncoder()
            if let encoderModel = try? encoder.encode(newFavorites) {
                UserDefaults.standard.set(encoderModel, forKey: "favorites")
            }
        }
    }
    
    // MARK: Public
    func setupCell(model: TopDataModel) {
        self.cellModel = model
        
        iconImageView.loadImageFromCache(withImageUrl: model.imageUrl)
        titleLabel.text = model.title
        rankLabel.text = "\(model.rank ?? 0)"
        startDateLabel.text = model.startDate
        endDateLabel.text = model.endDate
        typeLabel.text = model.type
        
        if let favoriteData = UserDefaults.standard.object(forKey: "favorites") as? Data {
            let decoder = JSONDecoder()
            if let savedTop = try? decoder.decode([TopDataModel].self, from: favoriteData) {
                if savedTop.contains(cellModel) {
                    favoriteButton.isSelected = true
                } else {
                    favoriteButton.isSelected = false
                }
            }
        }
    }
    
}
