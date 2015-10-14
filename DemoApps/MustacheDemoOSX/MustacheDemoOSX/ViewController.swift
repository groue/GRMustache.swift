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
    let font = NSFont(name: "Menlo", size: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for textView in [templateTextView, JSONTextView] {
            textView.automaticQuoteSubstitutionEnabled = false;
            textView.textStorage?.font = font
        }
    }
    
    @IBAction func render(sender: AnyObject) {
        do {
            let template = try Template(string: model.templateString)

            // Play with those goodies in your templates:
            // They are documented at https://github.com/groue/GRMustache.swift/blob/master/Guides/goodies.md
            
            let percentFormatter = NSNumberFormatter()
            percentFormatter.numberStyle = .PercentStyle
            template.registerInBaseContext("percent", Box(percentFormatter))
            template.registerInBaseContext("each", Box(StandardLibrary.each))
            template.registerInBaseContext("zip", Box(StandardLibrary.zip))
            template.registerInBaseContext("localize", Box(StandardLibrary.Localizer(bundle: nil, table: nil)))
            template.registerInBaseContext("HTMLEscape", Box(StandardLibrary.HTMLEscape))
            template.registerInBaseContext("URLEscape", Box(StandardLibrary.URLEscape))
            template.registerInBaseContext("javascriptEscape", Box(StandardLibrary.javascriptEscape))

            let data = model.JSONString.dataUsingEncoding(NSUTF8StringEncoding)!
            let JSONObject: AnyObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
            let string = try template.render(Box(JSONObject as? NSObject))
            presentRenderingString(string)
        }
        catch let error as NSError {
            presentRenderingString("\(error.domain): \(error.localizedDescription)")
        }
    }
    
    func presentRenderingString(string: String) {
        self.renderingTextView.string = string
        self.renderingTextView.textStorage?.font = font
    }
}
