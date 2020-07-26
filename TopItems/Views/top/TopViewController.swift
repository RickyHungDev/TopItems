//
//  TopViewController.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/25.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD

class TopViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var typeCollectionView: UIView!
    @IBOutlet weak var subtypeCollectionView: UIView!
    @IBOutlet weak var itemTableView: UIView!
    @IBOutlet weak var subtypeCollectionViewHeight: NSLayoutConstraint!
    
    var disposeBag: DisposeBag!
    var viewModel: TopViewModel!
    var typeVC: SelectCollectionViewController!
    var subtypeVC: SelectCollectionViewController!
    var itemVC: TopTableViewController!
    
    let typeSeletedItem: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var typeSeletedIndex: Int! = -1
    let subtypeSeletedItem: BehaviorRelay<Int> = BehaviorRelay(value: 0)
    var subtypeSeletedIndex: Int! = -1
    var topData: [TopDataModel] = []
    
    let topPage: BehaviorRelay<Int> = BehaviorRelay(value: 1)
    var isAppending: Bool = false
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        disposeBag = DisposeBag()
        viewModel = TopViewModel()
        setupObservables()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        disposeBag = nil
        viewModel = nil
    }
    
    // MARK: Initialize Setup
    private func setupViews() {
        let typeVC = SelectCollectionViewController()
        addChild(childController: typeVC, to: typeCollectionView)
        self.typeVC = typeVC
        self.typeVC.filters = TopTypes.allCases.map { $0.rawValue }
        self.typeVC.setSeletedItem(index: 0)
        
        let subtypeVC = SelectCollectionViewController()
        addChild(childController: subtypeVC, to: subtypeCollectionView)
        self.subtypeVC = subtypeVC
        
        let itemVC = TopTableViewController()
        addChild(childController: itemVC, to: itemTableView)
        self.itemVC = itemVC
        self.itemVC.delegate = self
    }
    
    private func setupObservables() {
        viewModel.errorMessage.asObservable().subscribe(onNext: { [unowned self](error) in
            if error != "" {
                self.displayError(title: "error", message: error)
            }
            self.itemVC.isCanLoadNextPage = false
        }).disposed(by: disposeBag)
        
        viewModel.isLoading.asObservable().subscribe(onNext: { [unowned self] (loading) in
            self.setActivityIndicator(withVisibility: loading)
        }).disposed(by: disposeBag)
        
        viewModel.topData.asObservable().subscribe(onNext: { [unowned self] (data) in
            guard data.count > 0 else { return }
            if self.isAppending {
                self.topData.append(contentsOf: data)
                self.itemVC.topData.append(contentsOf: data)
            } else {
                self.topData = data
                self.itemVC.topData = data
            }
            self.itemVC.isCanLoadNextPage = true
        }).disposed(by: disposeBag)
        
        typeVC.seletedItem.bind(to: typeSeletedItem)
        .disposed(by: disposeBag)
        
        subtypeVC.seletedItem.bind(to: subtypeSeletedItem)
        .disposed(by: disposeBag)
        
        itemVC.currentPage.bind(to: topPage)
            .disposed(by: disposeBag)
        
        typeSeletedItem.asObservable().observeOn(MainScheduler.asyncInstance).subscribe(onNext: { [unowned self] (index) in
            guard self.typeSeletedIndex != index else { return }
            guard let selectType = TopTypes.init(id: index) else { return }

            self.typeSeletedIndex = index
            self.itemVC.currentPage.accept(1)
            self.itemVC.isCanLoadNextPage = true
            self.isAppending = false
            
            switch selectType {
            case .Anime:
                self.subtypeCollectionViewHeight.constant = 50
                self.subtypeVC.filters = AnimeSubtype.allCases.map { $0.rawValue }
            case .Manga:
                self.subtypeCollectionViewHeight.constant = 50
                self.subtypeVC.filters = MangaSubtype.allCases.map { $0.rawValue }
            case .People:
                self.subtypeCollectionViewHeight.constant = 0
                self.subtypeVC.filters = []
            case .Characters:
                self.subtypeCollectionViewHeight.constant = 0
                self.subtypeVC.filters = []
            case .Favorite:
                self.subtypeCollectionViewHeight.constant = 0
                self.subtypeVC.filters = []
            }
            self.subtypeVC.seletedItem.accept(-1)
        }).disposed(by: disposeBag)
        
        subtypeSeletedItem.asObservable().subscribe(onNext: { [unowned self] (index) in
//            guard self.subtypeSeletedIndex != index else { return }
            guard let selectType = TopTypes.init(id: self.typeSeletedIndex) else { return }
            
            self.subtypeSeletedIndex = index
            self.itemVC.currentPage.accept(1)
            self.itemVC.isCanLoadNextPage = true
            self.isAppending = false
            
            if selectType == .Favorite {
                if let favoriteData = UserDefaults.standard.object(forKey: "favorites") as? Data {
                    let decoder = JSONDecoder()
                    if let savedTop = try? decoder.decode([TopDataModel].self, from: favoriteData) {
                        self.itemVC.topData = savedTop
                    }
                }
            } else {
                self.viewModel.loadTopDetail(topType: selectType, topSubtypeIndex: index, page: self.topPage.value)
            }
        }).disposed(by: disposeBag)
    }
    
    // MARK: Display Event
    func setActivityIndicator(withVisibility visibility: Bool) {
        if visibility {
            HUD.show(.progress, onView: self.view)
        } else {
            HUD.hide()
        }
    }
    
    private func displayError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension TopViewController: TopTableViewControllerDelegate {
    func didScrollToBottom(_ page: Int) {
        self.itemVC.isCanLoadNextPage = false
        self.isAppending = true
        let selectType = TopTypes.init(id: typeSeletedIndex)!
        self.viewModel.loadTopDetail(topType: selectType, topSubtypeIndex: subtypeSeletedIndex, page: topPage.value)
    }
    
    func didSelectItemIndex(_ index: Int) {
        let webVC = WebViewController()
        webVC.pageTitle = topData[index].title
        webVC.url = topData[index].url
        self.navigationController?.pushViewController(webVC, animated: true)
    }
}
