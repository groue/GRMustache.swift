//
//  Configuration.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import UIKit

class Configuration {
    var contentType: ContentType
    var baseContext: Context
    
    init() {
        contentType = .HTML
        baseContext = Context()
    }
    
    class var defaultConfiguration: Configuration {
        return Configuration()
    }
    
}
