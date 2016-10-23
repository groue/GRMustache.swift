// To run this playground, select and build the MustacheOSX scheme.

import Mustache

let percentFormatter = NumberFormatter()
percentFormatter.numberStyle = .percent

let template = try! Template(string: "{{# percent }}\nhourly: {{ hourly }}\ndaily: {{ daily }}\nweekly: {{ weekly }}\n    {{/ percent }}")
template.register(percentFormatter, forKey: "percent")
template.register(StandardLibrary.HTMLEscape, forKey: "HTMLEscape")
template.register(StandardLibrary.javascriptEscape, forKey: "javascriptEscape")
template.register(StandardLibrary.URLEscape, forKey: "URLEscape")
template.register(StandardLibrary.each, forKey: "each")
template.register(StandardLibrary.zip, forKey: "zip")

let localizer = StandardLibrary.Localizer(bundle: nil, table: nil)
template.register(localizer, forkey: "localize")
let logger = StandardLibrary.Logger()
template.extendBaseContext(Box(logger))

// Rendering:
//
//   hourly: 10%
//   daily: 150%
//   weekly: 400%

let data = [
    "hourly": 0.1,
    "daily": 1.5,
    "weekly": 4,
]
let rendering = try! template.render(Box(data))
