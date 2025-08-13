//
//  WebPageViewController.swift
//  TimeStream
//
//  Created by appssemble on 11.08.2021.
//

import UIKit
import WebKit

protocol WebPageViewControllerFlowDelegate: BaseViewControllerFlowDelegate {
}

class WebPageViewController: BaseViewController, WKNavigationDelegate {
    
    weak var flowDelegate: WebPageViewControllerFlowDelegate?
    
    var name: String!
    var url: URL!
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        title = name
        webView.navigationDelegate = self
        loading = true
        webView.load(URLRequest(url: url))
        
        addBackButton(delegate: flowDelegate)
    }
    
    // MARK: Web view delegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading = false
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
        loading = false
        showGenericError()
    }
}
