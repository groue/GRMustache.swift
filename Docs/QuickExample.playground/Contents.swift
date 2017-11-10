// To run this playground, select and build the MustacheOSX scheme.

import Mustache

// Renders "Hello Arthur"
let template = try! Template(string: "Hello {{ name }}")
let rendering = try! template.render(["name": "Arthur"])
print(rendering)
