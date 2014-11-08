#!/usr/bin/ruby

here = File.expand_path(File.dirname(__FILE__))

require "docopt"
require File.join(here, "swatted")




doc = <<DOCOPT

NAME:
	swatted - list github issues closed since the last release.

USAGE:
	swatted [(-j|--json) | (-y|--yaml) | (-c|--changelog) | (--template=<template>)] [--regexp=<pattern>]
	swatted (-h|--help|--version)

DESCRIPTION:
	Swatted prints the github issues closed since your last release.

	By default, any tag is considered as pointing to a release, but a
	regular expression can be supplied to select which tags are released.


OPTIONS:
	-j --json                    Print matching issues in json format.
	-y --yaml                    Print matching issues in yaml format.
	-c --changelog=<template>    Print matching issues in a format that can be used in changelogs.
	--template=<template>        Print issues using a custom template string taking two variables:
	                             'title' - the issue title - and 'number' - the issue number.
	--regexp=<pattern>           A regular expression by which to select release tags.

	-h --help --version          Display this documentation.

DOCOPT





begin
	main(Docopt::docopt(doc))
rescue Docopt::Exit => e
	puts e.message
end
