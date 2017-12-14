//
//  ArticleContentViewController.swift
//  TellemApp
//
//  Created by Sean Bukich on 10/12/17.
//  Copyright © 2017 Sean Bukich. All rights reserved.
//

import UIKit
import WebKit

class ArticleContentViewController: UIViewController, WKUIDelegate {

    @IBOutlet weak var newsWebView: WKWebView!
    var webURL = "https://www.google.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("We made it ! ", #line, #function, "<")
        
        newsWebView.uiDelegate = self
        newsWebView.load(URLRequest(url: URL(string: webURL)!))
    }
}
