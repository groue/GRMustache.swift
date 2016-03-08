//
//  ViewController.swift
//  OSX
//
//  Created by Gwendal Roué on 18/05/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//

import Cocoa
import WebKit
import Mustache

class ViewController: NSViewController {
    @IBOutlet weak var webView: WebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let template = Template(named: "Document")!
        let data = ["name": "Frank Zappa"]
        let rendering = template.render(Box(data))!
        
        webView.mainFrame.loadHTMLString(rendering, baseURL: nil)
    }
}

