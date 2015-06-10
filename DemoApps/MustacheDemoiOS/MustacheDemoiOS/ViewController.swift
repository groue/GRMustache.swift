//
//  ViewController.swift
//  MustacheDemoiOS
//
//  Created by Gwendal Roué on 10/03/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//

import UIKit
import Mustache

class ViewController: UIViewController {
    @IBOutlet var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let template = try! Template(named: "Document")
        let rendering = try! template.render()
        webView.loadHTMLString(rendering, baseURL: nil)
    }
}
