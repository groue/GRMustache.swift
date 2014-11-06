//
//  MustacheTemplate.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

public class MustacheTemplate: MustacheRenderable {
    let repository: MustacheTemplateRepository
    let templateAST: TemplateAST
    var baseContext: Context
    
    init(repository: MustacheTemplateRepository, templateAST: TemplateAST, baseContext: Context) {
        self.repository = repository
        self.templateAST = templateAST
        self.baseContext = baseContext
    }
    
    convenience init?(string: String, error outError: NSErrorPointer = nil) {
        let repository = RenderingEngine.currentTemplateRepository() ?? MustacheTemplateRepository(bundle: nil)
        let contentType = RenderingEngine.currentContentType()
        if let templateAST = repository.templateAST(string: string, contentType: contentType, templateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    convenience init?(path: String, encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer = nil) {
        let repository = MustacheTemplateRepository(directoryPath: path.stringByDeletingLastPathComponent, templateExtension: path.pathExtension, encoding: encoding)
        let templateName = path.stringByDeletingPathExtension
        if let templateAST = repository.templateAST(named: templateName, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    convenience init?(URL: NSURL, encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer = nil) {
        let repository = MustacheTemplateRepository(baseURL: URL.URLByDeletingLastPathComponent!, templateExtension: URL.pathExtension, encoding: encoding)
        let templateName = URL.URLByDeletingPathExtension?.lastPathComponent
        if let templateAST = repository.templateAST(named: templateName!, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    convenience init?(named name: String, bundle: NSBundle? = nil, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer = nil) {
        let repository = MustacheTemplateRepository(bundle: bundle, templateExtension: templateExtension, encoding: encoding)
        if let templateAST = repository.templateAST(named: name, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    func render(value: MustacheValue, error outError: NSErrorPointer = nil) -> String? {
        let context = baseContext.contextByAddingValue(value)
        var contentType: ContentType = .Text
        return render(context, contentType: &contentType, error: outError)
    }
    
    func render(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        return render(renderingInfo.context, contentType: outContentType, error: outError)
    }
    
    class func render(value: MustacheValue, fromString string: String, error outError: NSErrorPointer = nil) -> String? {
        if let template = MustacheTemplate(string: string, error: outError) {
            return template.render(value, error: outError)
        } else {
            return nil
        }
    }
    
    
    // MARK: - MustacheRenderable
    
    func renderForMustacheTag(tag: MustacheTag, renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        return render(renderingInfo.context, contentType: outContentType, error: outError)
    }
    
    
    // MARK: - Private
    
    private func render(context: Context, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        RenderingEngine.pushCurrentTemplateRepository(repository)
        let rendering = renderingEngine.render(templateAST, contentType: outContentType, error: outError)
        RenderingEngine.popCurrentTemplateRepository()
        return rendering
    }
}
