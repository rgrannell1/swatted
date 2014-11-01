
require "rugged"
require 'github_api'




here   = Dir.pwd
repo   = Rugged::Repository.new(here)

remote = repo.remotes.map {|remote| File.basename(remote.url)}





credentials = {
	:username => IO.readlines(".credentials")[0].chop,
	:password => IO.readlines(".credentials")[1].chop
}





github = Github.new login: credentials[:username], password: credentials[:password]
issues = Github::Client::Issues.new

releases = (github.repos.tags 'rgrannell1', 'kea').map do |tag|
	{
		:commit_sha => tag.commit.sha,
		:name       => tag.name
	}
end

closed = (issues.list user: 'rgrannell1', repo: 'kea', state: 'closed').map do |issue|
	{
		:title     => issue.title,
		:number    => issue.number,
		:closed_at => issue.closed_at
	}
end

commits = (github.repos.commits.all 'rgrannell1', 'kea').map do |commit|
	{
		:sha  => commit.sha,
		:date => commit.commit.author.date
	}
end
