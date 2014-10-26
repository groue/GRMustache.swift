//
//  MustacheRenderable.swift
//  GRMustache
//
//  Created by Gwendal Roué on 26/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

struct RenderingOptions {
    let context: Context
    let enumerationItem: Bool
}

enum MustacheValue {
    case none
    case string(String)
    case dictionary([String: MustacheValue])
    
    var mustacheBoolValue: Bool {
        switch self {
        case .none:
            return false
        case .string(let string):
            return countElements(string) > 0
        case .dictionary:
            return true
        }
    }
    
    func renderMustacheTag(tag: Tag, options: RenderingOptions, error outError: NSErrorPointer) -> (rendering: String, contentType: ContentType)? {
        switch self {
        case .none:
            switch tag.type {
            case .Variable:
                return (rendering: "", contentType: .HTML)
            case .Section, .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .string(let string):
            switch tag.type {
            case .Variable:
                return (rendering:string, contentType:.Text)
                
            case .Section:
                let context = options.context.contextByAddingValue(self)
                return tag.renderContentWithContext(context, error: outError)
                
            case .InvertedSection:
                return tag.renderContentWithContext(options.context, error: outError)
            }
        case .dictionary(let dictionary):
            switch tag.type {
            case .Variable:
                return (rendering:"\(self)", contentType:.Text)
                
            case .Section, .InvertedSection:
                let context = options.context.contextByAddingValue(self)
                return tag.renderContentWithContext(context, error: outError)
            }
        }
    }
    
    func valueForMustacheIdentifier(identifier: String) -> MustacheValue {
        switch self {
        case .none:
            return .none
        case .string(let string):
            return .none
        case .dictionary(let dictionary):
            if let value = dictionary[identifier] {
                return value
            } else {
                return .none
            }
        }
    }
}
