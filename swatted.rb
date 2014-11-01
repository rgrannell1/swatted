
require "uri"
require "rugged"
require "github_api"





=begin

	load_credentials :: string -> { :username => string, :password => string }

	Load github credentials from an external file.

=end

def load_credentials (fpath = File.join(Dir.pwd, ".credentials"))

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

def infer_github_details (dpath = Dir.pwd)

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

	auth_github :: string x string -> Github

	Create a (possibly authenticated) github instance.

=end

def auth_github(username = "", password = "")

	if username.length * password.length == 0
		Github.new
	else
		Github.new login: credentials[:username], password: credentials[:password]
	end

end



def list_tags (github, details)

	commits = (github.repos.commits.all 'rgrannell1', 'kea').map do |commit|
		{
			:sha  => commit.sha,
			:date => commit.commit.author.date
		}
	end

	(github.repos.tags details[:username], details[:reponame]).map do |tag|
		{
			:sha  => tag.commit.sha,
			:name => tag.name,
			:date => commits.select {|commit| tag[:sha] == commit[:sha]}.first[:date]
		}
	end

end

list_tags(auth_github(), infer_github_details())







issues = Github::Client::Issues.new



closed = (issues.list user: 'rgrannell1', repo: 'kea', state: 'closed').map do |issue|
	{
		:title     => issue.title,
		:number    => issue.number,
		:closed_at => issue.closed_at
	}
end

