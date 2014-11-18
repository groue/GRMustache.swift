//
//  Localizer.swift
//  GRMustache
//
//  Created by Gwendal Roué on 31/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

public class Localizer: Filter, Renderable, TagObserver {
    public let bundle: NSBundle
    public let table: String?
    var formatArguments: [String]?
    
    public init(bundle: NSBundle?, table: String?) {
        self.bundle = bundle ?? NSBundle.mainBundle()
        self.table = table
    }
    
    
    // MARK: - Filter
    
    public func mustacheFilterByApplyingArgument(argument: Value) -> Filter? {
        return nil
    }
    
    public func transformedMustacheValue(value: Value, error: NSErrorPointer) -> Value? {
        if let string = value.toString() {
            return Value(localizedStringForKey(string))
        } else {
            return Value()
        }
    }
    
    
    // MARK: - Renderable
    
    public func renderForMustacheTag(tag: Tag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        
        /**
        * Perform a first rendering of the section tag, that will turn variable
        * tags into a custom placeholder.
        *
        * "...{{name}}..." will get turned into "...GRMustacheLocalizerValuePlaceholder...".
        *
        * For that, we make sure we are notified of tag rendering, so that our
        * mustacheTag:willRenderObject: implementation tells the tags to render
        * GRMustacheLocalizerValuePlaceholder instead of the regular values,
        * "Arthur" or "Barbara". This behavior is trigerred by the nil value of
        * self.formatArguments.
        */
        
        // Set up first pass behavior
        formatArguments = nil
        
        // Get notified of tag rendering
        let renderingInfo = renderingInfo.renderingInfoByExtendingContextWithTagObserver(self)
        
        // Render the localizable format
        if let localizableFormat = tag.renderContent(renderingInfo, contentType: outContentType, error: outError) {
            
            /**
            * Perform a second rendering that will fill our formatArguments array with
            * HTML-escaped tag renderings.
            *
            * Now our mustacheTag:willRenderObject: implementation will let the regular
            * values go through normal rendering ("Arthur" or "Barbara"). Our
            * mustacheTag:didRenderObject:as: method will fill self.formatArguments.
            *
            * This behavior is not the same as the previous one, and is trigerred by
            * the non-nil value of self.formatArguments.
            */
            
            // Set up second pass behavior
            formatArguments = []
            
            // Fill formatArguments
            tag.renderContent(renderingInfo, contentType: outContentType, error: outError)
            
            
            /**
            * Localize the format, and render.
            */
            
            var rendering: String
            if formatArguments!.isEmpty {
                rendering = localizedStringForKey(localizableFormat)
            } else {
                /**
                * When rendering {{#localize}}%d {{name}}{{/localize}},
                * The localizableFormat string we have just built is
                * "%d GRMustacheLocalizerValuePlaceholder".
                *
                * In order to get an actual format string, we have to:
                * - turn GRMustacheLocalizerValuePlaceholder into %@
                * - escape % into %%.
                *
                * The format string will then be "%%d %@".
                */
                
                var localizableFormat = localizableFormat.stringByReplacingOccurrencesOfString("%", withString: "%%")
                localizableFormat = localizableFormat.stringByReplacingOccurrencesOfString(Placeholder.string, withString: "%@")
                let localizedFormat = localizedStringForKey(localizableFormat)
                rendering = stringWithFormat(format: localizedFormat, argumentsArray: formatArguments!)
            }
            
            formatArguments = nil
            return rendering
        } else {
            return nil
        }
    }
    
    
    // MARK: - TagObserver
    
    public func mustacheTag(tag: Tag, willRenderValue value: Value) -> Value {
        switch tag.type {
        case .Variable:
            // {{ value }}
            //
            // We behave as stated in renderForMustacheTag(tag:,renderingInfo:,contentType:,error:)
            
            if formatArguments == nil {
                return Value(Placeholder.string)
            } else {
                return value
            }
            
        case .Section:
            // {{# value }}
            // {{^ value }}
            //
            // We do not want to mess with Mustache handling of boolean sections
            // such as {{#true}}...{{/}}.
            return value
        }
    }
    
    public func mustacheTag(tag: Tag, didRender rendering: String?, forValue: Value) {
        switch tag.type {
        case .Variable:
            // {{ value }}
            //
            // We behave as stated in renderForMustacheTag(tag:,renderingInfo:,contentType:,error:)
            
            if formatArguments != nil {
                if let rendering = rendering {
                    formatArguments!.append(rendering)
                }
            }
            
        case .Section:
            // {{# value }}
            // {{^ value }}
            break
        }
    }
    
    
    // MARK: - Private
    
    private func localizedStringForKey(key: String) -> String {
        return bundle.localizedStringForKey(key, value:"", table:table)
    }
    
    private func stringWithFormat(#format: String, argumentsArray args:[String]) -> String {
        switch countElements(args) {
        case 0:
            return format
        case 1:
            return String(format: format, args[0])
        case 2:
            return String(format: format, args[0], args[1])
        case 3:
            return String(format: format, args[0], args[1], args[2])
        case 4:
            return String(format: format, args[0], args[1], args[2], args[3])
        case 5:
            return String(format: format, args[0], args[1], args[2], args[3], args[4])
        case 6:
            return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5])
        case 7:
            return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6])
        case 8:
            return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7])
        case 9:
            return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8])
        case 10:
            return String(format: format, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9])
        default:
            fatalError("Not implemented: format with \(countElements(args)) parameters")
        }
    }
    
    struct Placeholder {
        static let string = "GRMustacheLocalizerValuePlaceholder"
    }
}
