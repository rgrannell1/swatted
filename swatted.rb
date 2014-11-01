
require "uri"
require "rugged"
require "github_api"





=begin

	load_credentials :: string -> { :username => string, :password => string }

	Load github credentials from an external file.

=end

def load_credentials(fpath = File.join(Dir.pwd, ".credentials"))

	contents = IO.readlines(fpath)

	{
		:username => contents[0].chop,
		:password => contents[1].chop
	}

end





=begin

	infer_github_details :: string -> { :username => string, :reponame => string }

	Given the path to a local sourcecode repository, infer the username
	and reponame used on github as a remote.

=end

def infer_github_details(dpath = Dir.pwd)

	repo = Rugged::Repository.new(dpath)
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

=begin



=end











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
