#!/usr/bin/ruby

here = File.expand_path(File.dirname(__FILE__))

require "docopt"
require File.join(here, "swatted")




doc = <<DOCOPT

NAME:
	swatted - list github issues closed since the last release.

USAGE:
	swatted (-j|--json) | (-y|--yaml) | (-c|--changelog) | (--template=<template>)
	swatted (-h|--help|--version)

DESCRIPTION:
	Swatted prints the github issues closed since your last release.

	Optional flags are available to print in machine-readable formats like json and yaml,
	or to customise the human-readable text printed.

OPTIONS:
	-j --json                    Print matching issues in json format.
	-y --yaml                    Print matching issues in yaml format.
	-c --changelog=<template>    Print matching issues in a format that can be used in changelogs.
	--template=<template>        Print issues using a custom template string taking two variables:
	                             'title' - the issue title - and 'number' - the issue number.
	-h --help --version          Display this documentation.

DOCOPT





begin
	main(Docopt::docopt(doc))
rescue Docopt::Exit => e
	puts e.message
end
