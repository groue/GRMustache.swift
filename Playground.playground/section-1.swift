// To run this playground, select and build the MustacheOSX scheme.

import Mustache

enum MyError : ErrorType {
    case Error1
    case Error2
    
    var description: String { return "MyError" }
    var localizedDescription: String { return "MyError" }
}

do {
    throw MyError.Error1
} catch let error as NSError {
    // Error Domain=MyError Code=0 "The operation couldn’t be completed. (MyError error 0.)"
    error
    // "The operation couldn’t be completed. (MyError error 0.)"
    error.localizedDescription
}
