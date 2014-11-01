
require "docopt"
require "Swatted"






doc = <<DOCOPT

NAME:
	swatted - list github issues closed since last release.

USAGE:
	#{__FILE__} [<tag>]

DESCRIPTION:
	Swatted returns the github issues closed since a given version of
	a repository.

OPTIONS:
	<tag>

DOCOPT





begin

	args = Docopt::docopt(doc)
	puts args

rescue Docopt::Exit => e

	puts e.message

end
