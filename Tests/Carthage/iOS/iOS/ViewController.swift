//
//  ViewController.swift
//  iOS
//
//  Created by Gwendal Roué on 18/05/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//

import UIKit
import Mustache

class ViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let template = Template(named: "Document")!
        let data = ["name": "Frank Zappa"]
        let rendering = template.render(Box(data))!
        
        webView.loadHTMLString(rendering, baseURL: nil)
    }
}

