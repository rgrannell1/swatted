#!/usr/bin/ruby

require "uri"
require "time"
require "rugged"
require "github_api"
require 'json'
require 'yaml'



=begin

	get_remote_details :: string -> { :username => string, :reponame => string }

	Given the path to a local sourcecode repository, infer the username
	and reponame used on github as a remote.

=end

def get_remote_details (repo)

	details = repo.remotes
		.select {|remote| URI.parse(remote.url).host == "github.com"}
		.map    {|remote|

			parts = remote.url.split(File::SEPARATOR)

			{
				:username => parts[-2],
				:reponame => parts[-1].sub(/.git$/, "")
			}
	}

	if details.length === 0

		puts "No github repositories linked to #{Dir.pwd}"
		exit 1

	end

	if details.length > 1

		puts "Multiple github repositories linked to #{Dir.pwd}"
		exit 1

	end

	details[0]

end






def github_wrapper()

	begin
		Github.new
	rescue Exception => err

		puts "an error occurred while creating a github wrapper object"
		puts err.message
		exit 1

	end

end

=begin

	git_wrapper :: string -> Git

	Create a wrapper for a local git repository.

	@param dpath A string. The path to the local repository. Defaults
	to the current working directory.

	@return A git wrapper.

=end

def git_wrapper (dpath = Dir.pwd)

	begin
		Rugged::Repository.new(dpath)

	rescue Rugged::RepositoryError => err

		puts "could not find repository at #{dpath}"
		exit 1

	rescue Exception => err

		puts "an error occurred while opening .git repository for #{dpath}"
		puts err.message
		exit 1

	end

end





=begin

	list_tags :: Git -> [Tag]

	Return the name, sha id, and creation date of each tag.

	@param git. A wrapper for a local git repository.

	@return an array of tags.

=end

def list_tags (git, pattern)

	is_tag     = /refs\/tags\//
	is_release = Regexp.new (pattern ||= ".+")

	begin

		walker = Rugged::Walker.new(git)
		walker.push(git.head.target_id)

	rescue Rugged::ReferenceError => err
		# -- there are likely no commits in the repo.

		return []

	rescue Exception => err

		puts "an error occurred while traversing github issues."
		puts err.message
		exit 1

	end

	commits = walker.map do |commit|
		{
			:sha  => commit.oid,
			:date => commit.time.to_time.to_i
		}
	end

	walker.reset

	git
	.references
	.select {|ref| is_tag    .match(ref.name)}
	.select {|ref| is_release.match(File.basename(ref.name))}
	.map    {|ref|

		target_commit = git.lookup(ref.target.oid).target

		{
			:time => target_commit.time.to_time.to_i,
			:sha  => target_commit.oid,
			:name => File.basename(ref.name)
		}
	}

end





=begin

	newest_tag :: [Tag] -> Tag
	where
		Tag <- {:sha => string,   :name => string,   :date => number}

	Get the most recently created tag.

	@param tags. An array of tags.

	@return A single tag.

=end

def newest_tag (tags)

	tag = tags.inject({:time => -1}) {|best, tag|
		tag[:time] > best[:time] ? tag : best
	}

	if tag[:time] == -1
		puts "no previous releases found for #{Dir.pwd}."
		exit 1
	else
		tag
	end

end




=begin

	list_closed_issues :: Github x Details -> [Issue],
	where
		Github is a github wrapper.
		Details
		Issue <- {:title => string, :number => number, :closed_at => number}

	@param github. A github object.
	@param details.

	@return An array of github issues.

=end

def list_closed_issues (github, details)

	begin

		(Github::Client::Issues.new.list user: details[:username], repo: details[:reponame], state: 'closed')
		.map {|issue|
			{
				:title     => issue.title,
				:number    => issue.number,
				:closed_at => Date.parse(issue[:closed_at]).to_time.to_i
			}
		}

	rescue Github::Error::NotFound => _

		puts "issues not found for #{details[:username]}/#{details[:reponame]}:"
		exit 1

	rescue Exception => err

		puts "an error occurred while retrieving issues for #{details[:username]}/#{details[:reponame]}:"
		puts err.message
		exit 1

	end

end





=begin

	recent_closed_issues :: Tag x [Issue] -> [Issue],
	where
		Tag   <- {:sha => string,   :name => string,   :date => number}
		Issue <- {:title => string, :number => string, :closed_at => number}

	@param tag.    The most recent tag created.
	@param issues. An array of github issues.

	@return An array of github issues.

=end

def closed_since_tag (tag, issues)
	issues.select {|issue| issue[:closed_at] > tag[:time]}
end

=begin

	closed_this_release :: Git -> Github -> [Issue],
	where
		Issue <- {:title => string, :number => string, :closed_at => number}

	Get all issues closed since the last release.

	@param git. A git object.
	@param github. A github object.

	@return An array of github issues.

=end


def closed_this_release (git, github, pattern)

	tags    = list_tags git, pattern
	closed  = list_closed_issues github, get_remote_details(git)
	closed_since_tag newest_tag(tags), closed

end


=begin

	stringify_issues :: [Issue] -> string,
	where
		Issue <- {:title => string, :number => string, :closed_at => number}

	format a list of issues as a human or machine-readable string.

	@param issues. An array of github issues.

	@return a string.

=end

def stringify_issues (issues, config)

	if config[:yaml]
		puts issues.to_yaml
	elsif config[:json]
		puts issues.to_json
	else config[:changelog] or true
		# -- named substitution not working, so ordered substitution for now.
		puts issues.map { |row| "* Closed #%s ('%s')" % [row[:number], row[:title]] }.join("\n")
	end

end



=begin

	validate_args ::

	Check that all the supplied arguments are valid.

=end

def validate_args (args)
	# todo
end





=begin

	get_pattern ::

	get the pattern to be used to match release tags.

=end

def release_pattern (args)

	if args["-s"] or args["--semver"]
		# -- credit to /sindresorhus/semver-regex for the regular expression
		# -- (it was released under the MIT licence)

		/\bv?(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)(?:-[\da-z\-]+(?:\.[\da-z\-]+)*)?(?:\+[\da-z\-]+(?:\.[\da-z\-]+)*)?\b/

	elsif !args["--regexp"].nil?
		Regexp.new args["--regexp"]
	else
		/.*?/
	end

end


def main (args)

	validate_args args

	stringify_issues closed_this_release(git_wrapper, github_wrapper, release_pattern(args)), {

		:json      => (args["-j"] or args["--json"]),
		:yaml      => (args["-y"] or args["--yaml"]),

		:changelog => (args["-c"] or args["--changelog"])
	}

end
