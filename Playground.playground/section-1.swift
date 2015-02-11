// To run this playground, select and build the MustacheOSX scheme.

import Mustache

var template: Template
var rendering: String

// Renders "Hello Arthur"
template = Template(string: "Hello {{ name }}")!
rendering = template.render(Box(["name": "Arthur"]))!
println(rendering)
