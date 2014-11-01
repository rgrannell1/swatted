
require "uri"
require "time"
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





=begin

	github_conn :: string x string -> Github

	Create a (possibly authenticated) github instance.

=end

def github_conn(username = "", password = "")

	if username.length * password.length == 0
		Github.new
	else
		Github.new login: credentials[:username], password: credentials[:password]
	end

end





=begin

=end

def git_conn (dpath = Dir.pwd)
	Rugged::Repository.new(dpath)
end





=begin

	list_tags :: Git -> [Tag]

	Return the name, sha id, and creation date of each tag.

	@param git. A connection to a local git repository.

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
		Github is a github connection.
		Details
		Issue <- {:title => string, :number => string, :closed_at => number}

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




def format_issues (issues)

end





def main (args)

	github  = github_conn()
	git     = git_conn "/home/ryan/Code/kea.R"


	details = infer_github_details git

	tags    = list_tags git, github, details
	closed  = list_closed_issues github, details

	changed = filter_closed_issues(most_recent_tag(tags), closed)

	format_issues changed

end

main({})
