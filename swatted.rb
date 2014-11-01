
require 'uri'
require "rugged"
require 'github_api'





def loadCredentials(fpath)

	contents = IO.readlines(fpath)

	{
		:username => contents[0].chop,
		:password => contents[1].chop
	}

end

def infer_github_details()

	repo = Rugged::Repository.new(Dir.pwd)
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





puts infer_github_details()





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
