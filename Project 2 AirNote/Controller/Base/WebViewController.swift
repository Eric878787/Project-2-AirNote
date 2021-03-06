//
//  WebViewController.swift
//  Project 2 AirNote
//
//  Created by Eric chung on 2022/5/9.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    // MARK: Properties
    private var webView: WKWebView!
    var urlString = ""
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: urlString)
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    // MARK: Methods
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
}
