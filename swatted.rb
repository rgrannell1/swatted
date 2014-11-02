#!/usr/bin/env ruby

require "uri"
require "time"
require "rugged"
require "github_api"
require 'json'
require 'yaml'



=begin

	infer_github_details :: string -> { :username => string, :reponame => string }

	Given the path to a local sourcecode repository, infer the username
	and reponame used on github as a remote.

=end

def infer_github_details (repo)

	urls = repo.remotes
		.select {|remote| URI.parse(remote.url).host == "github.com"}
		.map    {|remote| remote.url}

	details = urls.map do |url|

		parts = url.split(File::SEPARATOR)

		{
			:username => parts[-2],
			:reponame => parts[-1].sub(/.git$/, "")
		}

	end

	raise "No remote repositories found." if details.length == 0
	details[0]

end






def github_conn()
	Github.new
end

=begin

	git_conn :: string -> Git

	Create a wrapper for a local git repository.

	@param dpath A string. The path to the local repository. Defaults
	to the current working directory.

	@return A git wrapper.

=end

def git_conn (dpath = Dir.pwd)
	Rugged::Repository.new(dpath)
end





=begin

	list_tags :: Git -> [Tag]

	Return the name, sha id, and creation date of each tag.

	@param git. A wrapper for a local git repository.

	@return an array of tags.

=end

def list_tags (git)

	walker = Rugged::Walker.new(git)
	walker.push(git.head.target_id)

	commits = walker.map do |commit|
		{
			:sha  => commit.oid,
			:date => commit.time.to_time.to_i
		}
	end

	walker.reset

	tags_refs = git.references.select {|ref| /refs\/tags\//.match(ref.name)}
	tags_refs.map do |ref|

		target_commit = git.lookup(ref.target.oid).target

		{
			:time => target_commit.time.to_time.to_i,
			:sha  => target_commit.oid,
			:name => File.basename(ref.name)
		}

	end

end





=begin

	most_recent_tag :: [Tag] -> Tag
	where
		Tag <- {:sha => string,   :name => string,   :date => number}

	Get the most recently created tag.

	@param tags. An array of tags.

	@return A single tag.

=end

def most_recent_tag (tags)

	most_recent = tags.inject({:time => -1}) {|acc, tag|
		tag[:time] > acc[:time] ? tag : acc
	}

	raise "no previous releases" if most_recent[:time] == -1

	most_recent

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

	issues = Github::Client::Issues.new

	closed = (issues.list user: details[:username], repo: details[:reponame], state: 'closed').map do |issue|
		{
			:title     => issue.title,
			:number    => issue.number,
			:closed_at => Date.parse(issue[:closed_at]).to_time.to_i
		}
	end

end





=begin

	filter_closed_issues :: Tag x [Issue] -> [Issue],
	where
		Tag   <- {:sha => string,   :name => string,   :date => number}
		Issue <- {:title => string, :number => string, :closed_at => number}

	@param tag.    The most recent tag created.
	@param issues. An array of github issues.

	@return An array of github issues.

=end

def filter_closed_issues (tag, issues)

	issues.select do |issue|
		issue[:closed_at] > tag[:time]
	end

end



=begin

	stringify_issues :: [Issue] -> string,
	where
		Issue <- {:title => string, :number => string, :closed_at => number}

	format a list of issues as a human or machine readable string.

	@param issues. An array of github issues.

	@return a string.

=end

def stringify_issues (issues, flag)

	if flag[:yaml]

		puts issues.to_yaml

	elsif flag[:json]

		puts issues.to_json

	elsif flag[:pretty]

	else flag[:changelog] or true

		puts issues
		.map {|row|
			"* Closed ##{row[:number]} ('#{row[:title]}')"
		}.join('\n')

	end

end





def validate_args (args)
	// validateme
end




def main (args)

	validate_args(args)

	github  = github_conn()
	git     = git_conn

	tags    = list_tags git
	closed  = list_closed_issues github, infer_github_details(git)
	changed = filter_closed_issues most_recent_tag(tags), closed

	stringify_issues changed, {
		:json      => (args["-j"] or args["--json"]),
		:yaml      => (args["-y"] or args["--yaml"]),
		:pretty    => (args["-p"] or args["--pretty"]),
		:changelog => (args["-c"] or args["--changelog"])
	}

end
