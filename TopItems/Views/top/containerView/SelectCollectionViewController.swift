//
//  SelectCollectionViewController.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SelectCollectionViewController: UIViewController {
    
    @IBOutlet weak var selectItemCollectionView: UICollectionView!
    
    var filters: [String] = [] {
        didSet {
            self.selectItemCollectionView.reloadData()
        }
    }
    let seletedItem: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        configureCollectionView()
    }
    
    // MARK: Initialize Setup
    private func configureCollectionView() {
        if let flowLayout = selectItemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let height = TopConsts.COLLECTIONVIEW_CELL_ROW_HEIGHT
            flowLayout.itemSize = CGSize(width: UICollectionViewFlowLayout.automaticSize.width, height: height)
            flowLayout.estimatedItemSize = CGSize(width: TopConsts.COLLECTIONVIEW_CELL_ROW_HEIGHT, height: height)
            flowLayout.scrollDirection = .horizontal
        }
        
        for cellType in TopCollectionCells.allCellType {
            self.selectItemCollectionView.register(UINib(nibName: cellType.nibName, bundle: .main), forCellWithReuseIdentifier: cellType.identifier)
        }
        
        selectItemCollectionView.dataSource = self
        selectItemCollectionView.delegate = self
        
        selectItemCollectionView.layer.borderWidth = 1
        selectItemCollectionView.layer.borderColor = UIColor.black.cgColor
        DispatchQueue.main.async {
            self.selectItemCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: Action
    func setSeletedItem(index: Int) {
        let indexPathForSeletedRow = IndexPath(row: index, section: 0)
        selectItemCollectionView.selectItem(at: indexPathForSeletedRow, animated: false, scrollPosition: .centeredHorizontally)
        seletedItem.accept(index)
    }
    
}

extension SelectCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopCollectionCells.Item.identifier, for: indexPath) as! ItemCollectionViewCell
        cell.setupCell(title: filters[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.setSeletedItem(index: indexPath.row)
    }
    
}

