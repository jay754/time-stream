//
//  StripeWebViewController.swift
//  TimeStream
//
//  Created by appssemble on 16.11.2021.
//

import UIKit
import WebKit

protocol StripeWebViewControllerDelegate: AnyObject {
    func stripeWebViewHasFinished(vc: StripeWebViewController)
    func stripeWebViewReloadAccount(vc: StripeWebViewController)
}

class StripeWebViewController: BaseViewController, WKNavigationDelegate {
    
    weak var delegate: StripeWebViewControllerDelegate?
    
    var url: URL!
    
    private struct Constants {
        static let returnURL = "https://appssemble.com/time-return"
        static let refreshURL = "https://appssemble.com/time-reauth"
    }
    
    @IBOutlet weak var webView: WKWebView!
    
    
    static func loadFromXib(url: URL, delegate: StripeWebViewControllerDelegate) -> StripeWebViewController {
        let vc = StripeWebViewController(nibName: "StripeWebViewController", bundle: nil)
        vc.delegate = delegate
        vc.url = url
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        webView.navigationDelegate = self
        loading = true
        webView.load(URLRequest(url: url))
        
        addBackButton(selector: #selector(backPressed2))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.stripeWebViewHasFinished(vc: self)
    }
    
    @objc
    private func backPressed2() {
        print("back")
    }
    
    // MARK: Web view delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        loading = false
        showGenericError()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.request.url?.absoluteString == Constants.returnURL {
            delegate?.stripeWebViewHasFinished(vc: self)
            decisionHandler(.cancel)
            return
        }
        
        if navigationAction.request.url?.absoluteString == Constants.refreshURL {
            delegate?.stripeWebViewReloadAccount(vc: self)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
}


