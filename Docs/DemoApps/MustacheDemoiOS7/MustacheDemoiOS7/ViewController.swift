//
//  ViewController.swift
//  MustacheDemoiOS7
//
//  Created by Gwendal Roué on 14/10/2015.
//  Copyright © 2015 Gwendal Roué. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let template = try! Template(named: "Document")
        let rendering = try! template.render()
        webView.loadHTMLString(rendering, baseURL: nil)
    }
}
