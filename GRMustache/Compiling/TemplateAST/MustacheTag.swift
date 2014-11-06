//
//  MustacheTag.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

enum MustacheTagType {
    case Variable
    case Section
}

protocol MustacheTag {
    var expression: Expression { get }
    var type: MustacheTagType { get }
    var innerTemplateString: String { get }
    var inverted: Bool { get } // this should be protected
    
    func renderContent(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String?
}
