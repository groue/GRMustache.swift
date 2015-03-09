//: # GRMustache.swift Use Cases
//:
//: Rendering Mustache templates always involves loading a template, and then providing the data that should fill the Mustache tags.
//:
//: You can load templates from a string, from a file, or from a bundle resource.
import Mustache
var template: Template
template = Template(string: "{{name}} has a Mustache.")!
template = Template(path: NSBundle.mainBundle().pathForResource("hello", ofType: "mustache")!)!
template = Template(URL: NSBundle.mainBundle().URLForResource("hello", withExtension: "mustache")!)!
template = Template(named: "hello")!

//: Templates can be fed with nearly any kind of data. However templates can not eat raw values: you have to wrap them in a "box", using the Box() function:
let data = ["name": "Salvador Dali"]
template.render(Box(data))!

//: ## Errors
//:
//: Errors are not funny, but they happen.
//:
//: You may get errors when loading templates, such as I/O errors:
var error: NSError?
Template(path: "/path/to/missing/template", error: &error)
error!.localizedDescription

//: Missing template errors:
Template(named: "inexistant", error: &error)
error!.localizedDescription

//: Parsing errors:
Template(string: "Hello {{name", error: &error)
error!.localizedDescription

//: You may also get an error when you render a template:
template = Template(string: "{{undefinedFilter(x)}}")!
template.render(error: &error)
error!.localizedDescription

//: When you render trusted valid templates with trusted valid data, you can avoid error handling:
template = Template(string: "{{name}} has a Mustache.")! // assume valid parsing
template.render(Box(data))!                              // assume valid rendering

//: ## Feeding Mustache templates
//:
//: Many values can feed Mustache templates. Most of the time, those values will fill Mustache tags such as {{name}}, so there must be a way to extract keys from them.
//:
//: Swift dictionaries and NSDictionary are obvious candidates:
let dictionary = ["name": "Albert Einstein"]
template.render(Box(dictionary))

//: NSObject subclasses can feed templates as well:
class ObjCPerson: NSObject {
    let name: String
    init(name: String) { self.name = name }
}
let objcPerson = ObjCPerson(name: "Tom Selleck")
template.render(Box(objcPerson))

//: Pure Swift types can be used, as long as they conform to the MustacheBoxable protocol:
struct SwiftPerson {
    let name: String
}
extension SwiftPerson : MustacheBoxable {
    var mustacheBox: MustacheBox {
        // Return a box that wraps self, and knows how to extract the "name" key:
        return Box(value: self) { (key: String) in
            switch key {
            case "name":
                return Box(self.name)
            default:
                return Box()
            }
        }
    }
}
let swiftPerson = SwiftPerson(name: "Charles Bronson")
template.render(Box(swiftPerson))

