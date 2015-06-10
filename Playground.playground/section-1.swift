// To run this playground, select and build the MustacheOSX scheme.

//import Mustache
//
//let percentFormatter = NSNumberFormatter()
//percentFormatter.numberStyle = .PercentStyle
//
//var template = try! Template(string: "{{ percent(x) }}")
//template.registerInBaseContext("percent", Box(percentFormatter))
//
//// Renders "50%"
//try! template.render(Box(["x": 0.5]))

let s = "toto"

func f(s: String) -> String {
    return s + "titi"
}

let x = f(s)
let slice = x[x.startIndex..<x.endIndex]
