//
//  TopTableViewController.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol TopTableViewControllerDelegate: class {
    func didSelectItemIndex(_ index: Int)
    func didScrollToBottom(_ page: Int)
}

class TopTableViewController: UIViewController {
    
    @IBOutlet weak var itemTableView: UITableView!
    
    var disposeBag: DisposeBag!
    var topData: [TopDataModel] = [] {
        didSet {
            self.itemTableView.reloadData()
        }
    }
    weak var delegate: TopTableViewControllerDelegate?
    
    var currentPage: BehaviorRelay<Int> = BehaviorRelay(value: 1)
    private let threshold: CGFloat = 100.0 // threshold from bottom of tableView
    var isCanLoadNextPage: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupViews()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        disposeBag = DisposeBag()
        setupObservables()
        setupAction()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disposeBag = nil
    }
    
    // MARK: Initialize Setup
    private func setupViews() {
        
    }
    
    private func configureTableView() {
        for cellType in TopTableViewCells.allCellType {
            self.itemTableView.register(UINib(nibName: cellType.nibName, bundle: .main), forCellReuseIdentifier: cellType.identifier)
        }
        
        itemTableView.dataSource = self
        itemTableView.delegate = self
        itemTableView.estimatedRowHeight = TopConsts.TABLEVIEW_CELL_ROW_HEIGHT
        itemTableView.rowHeight = UITableView.automaticDimension
        itemTableView.separatorStyle = .none
    }
    
    private func setupAction() {
        
    }
    
    private func setupObservables() {

    }
    
    // MARK: Configure Cell
    private func configureItemCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: TopTableViewCells.Item.identifier, for: indexPath) as! ItemTableViewCell
        cell.setupCell(model: topData[indexPath.row])
        return cell
    }
    
}


extension TopTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureItemCell(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectItemIndex(indexPath.row)
    }
}

extension TopTableViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard topData.count > 0 else {
            return
        }
        
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        if (maximumOffset - contentOffset <= threshold){
            //  loading More Data
                        
            //  show loading activity
            if isCanLoadNextPage {
                self.currentPage.accept(self.currentPage.value + 1)
                self.delegate?.didScrollToBottom(self.currentPage.value)
            }
        }
    }
}
