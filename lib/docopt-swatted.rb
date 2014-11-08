#!/usr/bin/ruby

here = File.expand_path(File.dirname(__FILE__))

require "docopt"
require File.join(here, "swatted")




doc = <<DOCOPT

NAME:
	swatted v0.1.0 - list github issues closed since the last release.

USAGE:
	swatted (-j|--json) | (-y|--yaml) | (-c|--changelog) [(--regexp=<pattern>) | (-s|--semver)]
	swatted (-h|--help|--version)

DESCRIPTION:

	Swatted prints the github issues closed since your last release.

OPTIONS:
	-j --json                   Print matching issues in json format. An empty array is returned
	                            when no issues are found.

	-y --yaml                   Print matching issues in yaml format. An empty list is returned
	                            when no issues are found.

	-s --semver                 Should tags matching the semantic versioning standard be assumed to be
	                            releases? If enabled, only tags matching this format are treated as releases,
	                            and additional tags are ignored.

	-c --changelog              Print matching issues in a format that can be used in change-logs. For example:
	                            "* Closed #3 ('submitting bug report formats hard-drive')".

	--regexp=<pattern>          A regular expression for release tags. By default, any tag is considered as
	                            pointing to a release.

	-h --help --version         Display this documentation.

DOCOPT





begin
	main(Docopt::docopt(doc))
rescue Docopt::Exit => e
	puts e.message
end
