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

            // Uncomment and play with those goodies in your templates:
            // They are documented at https://github.com/groue/GRMustache.swift/blob/master/Guides/goodies.md
            
//            let percentFormatter = NSNumberFormatter()
//            percentFormatter.numberStyle = .PercentStyle
//            template.registerInBaseContext("percent", Box(percentFormatter))
//            template.registerInBaseContext("each", Box(StandardLibrary.each))
//            template.registerInBaseContext("zip", Box(StandardLibrary.zip))
//            template.registerInBaseContext("localize", Box(StandardLibrary.Localizer(bundle: nil, table: nil)))
//            template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
//            template.registerInBaseContext("URLEscape", Box(StandardLibrary.URLEscape))
//            template.registerInBaseContext("javascriptEscape", Box(StandardLibrary.javascriptEscape))

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
