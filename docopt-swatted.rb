
require "docopt"
require "./swatted"





doc = <<DOCOPT

NAME:
	swatted - list github issues closed since last release.

USAGE:
	#{__FILE__} [ (-j|--json) | (-y|--yaml) | (-p | --pretty) ] -- [<tag>]

DESCRIPTION:
	Swatted returns the github issues closed since a given version of
	a repository.

OPTIONS:
	-j --json    Print matching issues in json format.
	-y --yaml    Print matching issues in yaml format.
	-p --pretty  Print matching issues in a human readable format (default).

	<tag>

DOCOPT





begin

	args = Docopt::docopt(doc)
	puts args

rescue Docopt::Exit => e

	puts e.message

end
