// To run this playground, select and build the MustacheOSX scheme.

import Mustache

// Renders "Hello Arthur"
let template = Template(string: "Hello {{ name }}")!
let rendering = template.render(Box(["name": "Arthur"]))!
println(rendering)
