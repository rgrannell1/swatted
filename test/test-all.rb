#!/usr/bin/env ruby

require "securerandom"





here = File.expand_path(File.dirname(__FILE__))
require File.join(File.dirname(here), "lib", "swatted")





def random_issue ()

	{
		:title  => SecureRandom.base64(256).split('').take(Random.rand(1...256)).join,
		:number => Random.rand(0...2147483647).to_s
	}

end





def deparse_identity (num)

	config_json = {
		:json      => true,
		:yaml      => false,
		:changelog => false
	}

	config_yaml = {
		:json      => true,
		:yaml      => false,
		:changelog => false
	}

	config_changelog = {
		:json      => true,
		:yaml      => false,
		:changelog => false
	}

	(0...num).map do |ith|

		issue = random_issue

		json_string          = stringify_issues issue, config_json
		reparsed_json_string = stringify_issues JSON.parse(json_string), config_json

		assert reparsed_json_string === json_string

	end
end





deparse_identity 10
