
require "docopt"
require "swatted"

doc = <<DOCOPT

NAME:
	swatted - list github issues closed since last release.

USAGE:
	#{__FILE__} <repo> <tag> --username=<username>

DESCRIPTION:

	Swatted returns the github issues closed since a given version of
	a repository.

OPTIONS:
	<repo> The name of a github repository.


DOCOPT





begin

	args = Docopt::docopt(doc)
	puts args

rescue Docopt::Exit => e

	puts e.message

end
