//
//  ItemCollectionViewCell.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = UIColor.red
            } else {
                titleLabel.textColor = UIColor.black
            }
        }
    }

    // MARK: View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupViews()
    }
    
    // MARK: Private
    private func setupViews() {
        
    }
    
    // MARK: Public
    func setupCell(title: String) {
        titleLabel.text = title
    }

}
