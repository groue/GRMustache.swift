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
    
    convenience init?(string: String, error outError: NSErrorPointer) {
        let repository = RenderingEngine.currentTemplateRepository() ?? MustacheTemplateRepository(bundle: nil)
        let contentType = RenderingEngine.currentContentType()
        if let templateAST = repository.templateASTFromString(string, contentType: contentType, templateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    convenience init?(templatePath: String, encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer) {
        let repository = MustacheTemplateRepository(directoryPath: templatePath.stringByDeletingLastPathComponent, templateExtension: templatePath.pathExtension, encoding: encoding)
        let templateName = templatePath.stringByDeletingPathExtension
        if let templateAST = repository.templateASTNamed(templateName, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    convenience init?(templateURL: NSURL, encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer) {
        let repository = MustacheTemplateRepository(baseURL: templateURL.URLByDeletingLastPathComponent!, templateExtension: templateURL.pathExtension, encoding: encoding)
        let templateName = templateURL.URLByDeletingPathExtension?.lastPathComponent
        if let templateAST = repository.templateASTNamed(templateName!, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    convenience init?(resource: String, bundle: NSBundle?, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding, error outError: NSErrorPointer) {
        let repository = MustacheTemplateRepository(bundle: bundle, templateExtension: templateExtension, encoding: encoding)
        if let templateAST = repository.templateASTNamed(resource, relativeToTemplateID: nil, error: outError) {
            self.init(repository: repository, templateAST: templateAST, baseContext: repository.configuration.baseContext)
        } else {
            // Failable initializers require all properties to be set.
            // So be it, with dummy values.
            self.init(repository: MustacheTemplateRepository(), templateAST: TemplateAST(), baseContext: Context())
            return nil
        }
    }
    
    func render(value: MustacheValue, error outError: NSErrorPointer) -> String? {
        let context = baseContext.contextByAddingValue(value)
        var contentType: ContentType = .Text
        return mustacheRendering(context, contentType: &contentType, error: outError)
    }
    
    class func render(value: MustacheValue, fromString string: String, error outError: NSErrorPointer) -> String? {
        if let template = MustacheTemplate(string: string, error: outError) {
            return template.render(value, error: outError)
        } else {
            return nil
        }
    }
    
    
    // MARK: - MustacheRenderable
    
    let mustacheBoolValue = true
    let mustacheFilter: MustacheFilter? = nil
    let mustacheTagObserver: MustacheTagObserver? = nil
    let mustacheTraversable: MustacheTraversable? = nil
    
    func mustacheRendering(renderingInfo: RenderingInfo, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        return mustacheRendering(renderingInfo.context, contentType: outContentType, error: outError)
    }
    
    
    // MARK: - Private
    
    private func mustacheRendering(context: Context, contentType outContentType: ContentTypePointer, error outError: NSErrorPointer) -> String? {
        let renderingEngine = RenderingEngine(contentType: templateAST.contentType, context: context)
        RenderingEngine.pushCurrentTemplateRepository(repository)
        let rendering = renderingEngine.mustacheRendering(templateAST, contentType: outContentType, error: outError)
        RenderingEngine.popCurrentTemplateRepository()
        return rendering
    }
}
