//
//  ViewController.swift
//  MustacheDemoOSX
//
//  Created by Gwendal Roué on 11/02/2015.
//  Copyright (c) 2015 Gwendal Roué. All rights reserved.
//

import Cocoa

class Model: NSObject {
    dynamic var templateString: String = "Hello {{ name }}!"
    dynamic var JSONString: String = "{\n  \"name\": \"Arthur\"\n}"
}
