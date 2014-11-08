#!/usr/bin/env ruby

require "securerandom"





here = File.expand_path(File.dirname(__FILE__))
require File.join(File.dirname(here), "lib", "swatted")




def issue_seq
	Enumerator.new do |enum|

		while true

			issue = {
				:title  => SecureRandom.base64(256).split('').take(Random.rand(1...256)).join,
				:number => Random.rand(0...2147483647).to_s,
				:time   => Random.rand(0...2147483647)
			}

			enum.yield issue

		end

	end
end




def config_seq
	Enumerator.new do |enum|

		while true

			config = {
				:yaml      => false,
				:json      => false,
				:changelog => false
			}


		end

	end
end
