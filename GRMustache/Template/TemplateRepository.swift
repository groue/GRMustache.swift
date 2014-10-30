//
//  TemplateRepository.swift
//  GRMustache
//
//  Created by Gwendal Roué on 25/10/2014.
//  Copyright (c) 2014 Gwendal Roué. All rights reserved.
//

import Foundation

typealias TemplateID = String

protocol TemplateRepositoryDataSource {
    func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID?
    func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String?
}

public class TemplateRepository {
    var configuration: Configuration
    var dataSource: TemplateRepositoryDataSource?
    var templateASTForTemplateID: [TemplateID: TemplateAST]
    
    public init() {
        configuration = Configuration.defaultConfiguration
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
    
    public func templateFromString(string: String, error outError: NSErrorPointer) -> Template? {
        return self.templateFromString(string, contentType: configuration.contentType, error: outError)
    }
    
    public func templateNamed(name: String, error outError: NSErrorPointer) -> Template? {
        if let templateAST = templateASTNamed(name, relativeToTemplateID: nil, error: outError) {
            return Template(templateRepository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    func templateFromString(string: String, contentType: ContentType, error outError: NSErrorPointer) -> Template? {
        if let templateAST = self.templateASTFromString(string, contentType: contentType, templateID: nil, error: outError) {
            return Template(templateRepository: self, templateAST: templateAST, baseContext: configuration.baseContext)
        } else {
            return nil
        }
    }
    
    func templateASTNamed(name: String, relativeToTemplateID templateID: TemplateID?, error outError: NSErrorPointer) -> TemplateAST? {
        if let templateID = dataSource?.templateIDForName(name, relativeToTemplateID: templateID, inRepository: self) {
            if let templateAST = templateASTForTemplateID[templateID] {
                return templateAST
            } else {
                var error: NSError?
                if let templateString = dataSource?.templateStringForTemplateID(templateID, error: &error) {
                    let templateAST = TemplateAST()
                    templateASTForTemplateID[templateID] = templateAST
                    if let compiledAST = templateASTFromString(templateString, contentType: configuration.contentType, templateID: templateID, error: outError) {
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
    
    
    // MARK: - Private
    
    private func templateASTFromString(string: String, contentType: ContentType, templateID: TemplateID?, error outError: NSErrorPointer) -> TemplateAST? {
        let compiler = TemplateCompiler(contentType: contentType, templateRepository: self, templateID: templateID)
        let parser = TemplateParser(tokenConsumer: compiler, configuration: configuration)
        parser.parse(string)
        return compiler.templateAST(error: outError)
    }
    
    class DictionaryDataSource: TemplateRepositoryDataSource {
        let templates: [String: String]
        
        init(templates: [String: String]) {
            self.templates = templates
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
            return name
        }
        
        func templateStringForTemplateID(templateID: TemplateID, error outError: NSErrorPointer) -> String? {
            return templates[templateID]
        }
    }
    
    class DirectoryDataSource: TemplateRepositoryDataSource {
        let directoryPath: String
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(directoryPath: String, templateExtension: String, encoding: NSStringEncoding) {
            self.directoryPath = directoryPath
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
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
    
    class URLDataSource: TemplateRepositoryDataSource {
        let baseURL: NSURL
        let templateExtension: String
        let encoding: NSStringEncoding
        
        init(baseURL: NSURL, templateExtension: String, encoding: NSStringEncoding) {
            self.baseURL = baseURL
            self.templateExtension = templateExtension
            self.encoding = encoding
        }
        
        func templateIDForName(name: String, relativeToTemplateID baseTemplateID: TemplateID?, inRepository:TemplateRepository) -> TemplateID? {
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
}
