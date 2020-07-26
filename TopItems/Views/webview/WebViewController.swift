//
//  WebViewController.swift
//  TopItems
//
//  Created by Hung Ricky on 2020/7/26.
//  Copyright © 2020 Hung Ricky. All rights reserved.
//

import UIKit
import WebKit
import PKHUD
import RxCocoa
import RxSwift

class WebViewController: UIViewController {
    var viewModel: WebViewModel!
    var webView: WKWebView!
    var url: String!
    var disposeBag: DisposeBag!
    var pageTitle: String!
    
    // MARK: View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
        }
        
        webView = WKWebView()
        view = webView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = true
        self.webView.navigationDelegate = self
        viewModel = WebViewModel()
        disposeBag = DisposeBag()
        setupObservables()
        
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if url != nil {
            self.setActivityIndicator(withVisibility: true)
            loadWebView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = false
        viewModel = nil
        disposeBag = nil
    }
    
    // MARK: Initialize Setup
    private func setupObservables() {
        viewModel.errorMessage.asObservable().subscribe(onNext: { [unowned self] (error) in
            if error != "" {
                self.displayError(title: "Error", message: error)
            }
        }).disposed(by: disposeBag)
        
        viewModel.isLoading.asObservable().subscribe(onNext: {[unowned self] (loading) in
            self.setActivityIndicator(withVisibility: loading)
        }).disposed(by: disposeBag)
    }
    
    private func setupNavigationBar() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        
        if let pageTitle = self.pageTitle {
            let titleLabel = UILabel()
            self.navigationController?.navigationBar.barTintColor = UIColor.gray
            let attributedTitle = NSMutableAttributedString (string: pageTitle)
            attributedTitle.addAttribute (NSAttributedString.Key.foregroundColor, value:UIColor.white, range:NSRange (location:0, length:attributedTitle.length))
            attributedTitle.addAttribute (NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20), range: NSRange (location:0, length:attributedTitle.length))
            
            titleLabel.attributedText = attributedTitle
            self.navigationItem.titleView = titleLabel
        }
    }
    
    // MARK: Private
    private func loadWebView() {
        let url = URL(string: self.url.replacingOccurrences(of: " ", with: ""))
        self.webView.load(URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 30))

        self.webView.allowsBackForwardNavigationGestures = true
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

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("REDIRECT")
        if(navigationAction.navigationType == .other)
        {
            if navigationAction.request.url != nil
            {

            }
        } else if (navigationAction.targetFrame == nil) {   // solve redirect to a new frame
            if navigationAction.request.url != nil
            {
                webView.load(navigationAction.request)
            }
        }
        decisionHandler(.allow)
        return
    }
    
    // When loading finishes
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.setActivityIndicator(withVisibility: false)
    }
    
    // When loading fail
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.setActivityIndicator(withVisibility: false)
        self.displayError(title: "Error", message: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.setActivityIndicator(withVisibility: false)
        self.displayError(title: "Error", message: error.localizedDescription)
    }
}
