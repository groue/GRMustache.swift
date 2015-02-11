//
//  ViewController.swift
//  MustacheDemoOSX
//
//  Created by Gwendal Roué on 11/02/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//

import Cocoa
import Mustache

class ViewController: NSViewController {
    
    @IBOutlet var templateTextView: NSTextView!
    @IBOutlet var JSONTextView: NSTextView!
    @IBOutlet var renderingTextView: NSTextView!
    
    @IBOutlet var model: Model!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        templateTextView.automaticQuoteSubstitutionEnabled = false;
        JSONTextView.automaticQuoteSubstitutionEnabled = false;
    }
    
    @IBAction func render(sender: AnyObject) {
        var error: NSError?
        if let template = Template(string: model.templateString, error: &error) {
            let data = model.JSONString.dataUsingEncoding(NSUTF8StringEncoding)!
            if let JSONObject: AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) {
                if let rendering = template.render(BoxAnyObject(JSONObject), error: &error) {
                    self.renderingTextView.string = rendering
                } else {
                    self.renderingTextView.string = "Mustache rendering error: \(error!.localizedDescription)"
                }
            } else {
                self.renderingTextView.string = "JSON error: \(error!.localizedDescription)"
            }
        } else {
            self.renderingTextView.string = "Mustache parsing error: \(error!.localizedDescription)"
        }
    }
}
