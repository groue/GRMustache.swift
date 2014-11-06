//
//  MustacheTemplateRepository.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

typealias TemplateID = String

protocol MustacheTemplateRepositoryDataSource {
    func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:MustacheTemplateRepository) -> TemplateID?
    func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String?
}

public class MustacheTemplateRepository {
    var configuration: MustacheConfiguration
    var dataSource: MustacheTemplateRepositoryDataSource?
    var templateASTForTemplateID: [TemplateID: TemplateAST]
    
    public init() {
        configuration = MustacheConfiguration.defaultConfiguration
        templateASTForTemplateID = [:]
    }
    
    convenience public init(templates: [String: String]) {
        self.init()
        dataSource = DictionaryDataSource(templates: templates)
    }
    
    convenience public init(directoryPath: String, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init()
        dataSource = DirectoryDataSource(directoryPath: directoryPath, templateExtension: templateExtension, encoding: encoding)
    }
    
    convenience public init(baseURL: NSURL, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init()
        dataSource = URLDataSource(baseURL: baseURL, templateExtension: templateExtension, encoding: encoding)
    }
    
    convenience public init(bundle: NSBundle?, templateExtension: String = "mustache", encoding: NSStringEncoding = NSUTF8StringEncoding) {
        self.init()
        dataSource = BundleDataSource(bundle: bundle ?? NSBundle.mainBundle(), templateExtension: templateExtension, encoding: encoding)
    }
    
    public func template(#string: String, error outError: NSErrorPointer = nil) -> MustacheTemplate? {
        return self.template(string: string, contentType: configuration.contentType, error: outError)
    }
    
    public func template(named name: String, error outError: NSErrorPointer = nil) -> MustacheTemplate? {
        if let templateAST = templateAST(named: name, relativeToTemplateID: nil, error: outError) {
            return MustacheTemplate(repository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    func template(#string: String, contentType: ContentType, error outError: NSErrorPointer) -> MustacheTemplate? {
        if let templateAST = self.templateAST(string: string, contentType: contentType, templateID: nil, error: outError) {
            return MustacheTemplate(repository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    func templateAST(named name: String, relativeToTemplateID templateID: TemplateID?, error outError: NSErrorPointer) -> TemplateAST? {
        if let templateID = dataSource?.templateIDForName(name, relativeToTemplateID: templateID, inRepository: self) {
            if let templateAST = templateASTForTemplateID[templateID] {
                return templateAST
            } else {
                var error: NSError?
                if let templateString = dataSource?.templateStringForTemplateID(templateID, error: &error) {
                    let templateAST = TemplateAST()
                    templateASTForTemplateID[templateID] = templateAST
                    if let compiledAST = self.templateAST(string: templateString, contentType: configuration.contentType, templateID: templateID, error: outError) {
                        templateAST.updateFromTemplateAST(compiledAST)
                        return templateAST
                    } else {
                        templateASTForTemplateID.removeValueForKey(templateID)
                        return nil
                    }
                } else {
                    if error == nil {
                        error = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
                    }
                    if outError != nil {
                        outError.memory = error
                    }
                    return nil
                }
            }
        } else {
            if outError != nil {
                outError.memory = NSError(domain: GRMustacheErrorDomain, code: GRMustacheErrorCodeTemplateNotFound, userInfo: [NSLocalizedDescriptionKey: "No such template: `\(name)`"])
            }
            return nil
        }
    }
    
    func templateAST(#string: String, contentType: ContentType, templateID: TemplateID?, error outError: NSErrorPointer) -> TemplateAST? {
        let compiler = TemplateCompiler(contentType: contentType, repository: self, templateID: templateID)
        let parser = TemplateParser(tokenConsumer: compiler, configuration: configuration)
        parser.parse(string)
        return compiler.templateAST(error: outError)
    }
    
    
    // MARK: - Private
    
    class DictionaryDataSource: MustacheTemplateRepositoryDataSource {
        let templates: [String: String]
        
        init(templates: [String: String]) {
            self.templates = templates
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:MustacheTemplateRepository) -> TemplateID? {
            return name
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String? {
            return templates[templateID]
        }
    }
    
    class DirectoryDataSource: MustacheTemplateRepositoryDataSource {
        let directoryPath: String
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(directoryPath: String, templateExtension: String, encoding: NSStringEncoding) {
            self.directoryPath = directoryPath
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:MustacheTemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            let templateFilename: String = {
                if self.templateExtension.isEmpty {
                    return normalizedName
                } else {
                    return normalizedName.stringByAppendingPathExtension(self.templateExtension)!
                }
            }()
            
            let templateDirectoryPath: String = {
                if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                    return normalizedBaseTemplateID.stringByDeletingLastPathComponent
                } else {
                    return self.directoryPath
                }
            }()
            
            return templateDirectoryPath.stringByAppendingPathComponent(templateFilename).stringByStandardizingPath
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String? {
            return NSString(contentsOfFile: templateID, encoding: encoding, error: outError)
        }
    }
    
    class URLDataSource: MustacheTemplateRepositoryDataSource {
        let baseURL: NSURL
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(baseURL: NSURL, templateExtension: String, encoding: NSStringEncoding) {
            self.baseURL = baseURL
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:MustacheTemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            let templateFilename: String = {
                if self.templateExtension.isEmpty {
                    return normalizedName
                } else {
                    return normalizedName.stringByAppendingPathExtension(self.templateExtension)!
                }
                }()
            
            let templateBaseURL: NSURL = {
                if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                    return NSURL(string: normalizedBaseTemplateID)!
                } else {
                    return self.baseURL
                }
            }()
            
            return NSURL(string: templateFilename, relativeToURL: templateBaseURL)!.URLByStandardizingPath!.absoluteString
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String? {
            return NSString(contentsOfURL: NSURL(string: templateID)!, encoding: encoding, error: outError)
        }
    }
    
    class BundleDataSource: MustacheTemplateRepositoryDataSource {
        let bundle: NSBundle
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(bundle: NSBundle, templateExtension: String, encoding: NSStringEncoding) {
            self.bundle = bundle
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository: MustacheTemplateRepository) -> TemplateID? {
            let (normalizedName, normalizedBaseTemplateID) = { () -> (String, TemplateID?) in
                // Rebase template names starting with a /
                if !name.isEmpty && name[name.startIndex] == "/" {
                    return (name.substringFromIndex(name.startIndex.successor()), nil)
                } else {
                    return (name, baseTemplateID)
                }
                }()
            
            if normalizedName.isEmpty {
                return normalizedBaseTemplateID
            }
            
            if let normalizedBaseTemplateID = normalizedBaseTemplateID {
                var relativePath = normalizedBaseTemplateID.stringByDeletingLastPathComponent
                relativePath = relativePath.stringByReplacingOccurrencesOfString(bundle.resourcePath!, withString:"")
                return bundle.pathForResource(normalizedName, ofType: templateExtension, inDirectory: relativePath)
            } else {
                return bundle.pathForResource(normalizedName, ofType: templateExtension)
            }
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String? {
            return NSString(contentsOfFile: templateID, encoding: encoding, error: outError)
        }
    }
}
