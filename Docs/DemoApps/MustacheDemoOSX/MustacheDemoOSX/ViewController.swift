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
        
        templateTextView.isAutomaticQuoteSubstitutionEnabled = false
        templateTextView.textStorage?.font = font
        
        JSONTextView.isAutomaticQuoteSubstitutionEnabled = false
        JSONTextView.textStorage?.font = font
    }
    
    @IBAction func render(_ sender: Any?) {
        do {
            let template = try Template(string: model.templateString)

            // Play with those goodies in your templates:
            // They are documented at https://github.com/groue/GRMustache.swift/blob/master/Guides/goodies.md
            
            let percentFormatter = NumberFormatter()
            percentFormatter.numberStyle = .percent
            template.register(percentFormatter, forKey: "percent")
            template.register(StandardLibrary.each, forKey: "each")
            template.register(StandardLibrary.zip, forKey: "zip")
            template.register(StandardLibrary.Localizer(), forKey: "localize")
            template.register(StandardLibrary.HTMLEscape, forKey: "HTMLEscape")
            template.register(StandardLibrary.URLEscape, forKey: "URLEscape")
            template.register(StandardLibrary.javascriptEscape, forKey: "javascriptEscape")

            let data = model.JSONString.data(using: .utf8)!
            let JSONObject = try JSONSerialization.jsonObject(with: data, options: [])
            let string = try template.render(Box(JSONObject as? NSObject))
            present(renderingString: string)
        }
        catch let error as NSError {
            present(renderingString: "\(error.domain): \(error.localizedDescription)")
        }
    }
    
    func present(renderingString string: String) {
        self.renderingTextView.string = string
        self.renderingTextView.textStorage?.font = font
    }
}
