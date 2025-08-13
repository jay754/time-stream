//
//  StripeWebViewController.swift
//  TimeStream
//
//  Created by appssemble on 16.11.2021.
//

import UIKit
import WebKit

protocol AdyenWebViewControllerDelegate: AnyObject {
    func adyenWebViewHasFinished(vc: AdyenWebViewController)
}

class AdyenWebViewController: BaseViewController, WKNavigationDelegate, WKUIDelegate {
    
    weak var delegate: AdyenWebViewControllerDelegate?
    
    var url: URL!
    
    private struct Constants {
        static let returnURL = "https://time.stream/adyen-time-return"
    }
    
    @IBOutlet weak var webView: WKWebView!
    
    
    static func loadFromXib(url: URL, delegate: AdyenWebViewControllerDelegate) -> AdyenWebViewController {
        let vc = AdyenWebViewController(nibName: "AdyenWebViewController", bundle: nil)
        vc.delegate = delegate
        vc.url = url
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        loading = true
        webView.load(URLRequest(url: url))
        
        addBackButton(selector: #selector(backPressed2))
    }
    
    @objc
    private func backPressed2() {
        dismiss(animated: true, completion: nil)
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
            delegate?.adyenWebViewHasFinished(vc: self)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_: WKWebView, createWebViewWith _: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures _: WKWindowFeatures) -> WKWebView? {
        self.webView?.load(navigationAction.request)
        return nil
    }
    
}


