module Subtrigger
  # = Subversion repostitory wrapper
  #
  # Use this class to get to the information for a specific commit in a
  # specific subversion repository. This is a simple wrapper around the
  # +svnlook+ command.
  #
  # This class will look for +svn+ and +svnlook+ on your system and will raise
  # an exception when it can not be found.
  #
  # == Usage example
  #
  #   repo = Repository.new('/path/to/repo', 5540)
  #   repo.author  # => 'Graham'
  #   repo.message # => 'Added copyright information to the readme'
  #   repo.changed_projects do |p|
  #     puts p     # => a changed directory above a trunk, branches or tags
  #   end
  #
  class Repository
    attr_reader :path, :revision

    # Initialize a new wrapper around a repository at a given revision.
    #
    # This will try to find the +svn+ executable on your system and raise
    # an exception when it cannot be found.
    #
    # Exceptions will also be raised when the repository path can not be
    # found or the revision is not numeric.
    def initialize(path, revision)
      raise "Repository '#{path}' not found" unless File.directory?(path)
      raise "Invalid revision number '#{revision}'" unless revision.to_i > 0
      @path = path
      @revision = revision.to_i
      @svn_path = Subtrigger.svn || `which svn`.strip
      raise 'Could not locate svn' if @svn_path.nil?
    end

    # Return the path to the current repository. If given an extra string,
    # that will be appended to the path.
    #
    # Example:
    #
    #   repo.path          # => '/path/to/repo'
    #   repo.path('mydir') # => '/path/to/repo/mydir'
    #
    def path(subpath = nil)
      return File.join(@path, subpath) unless subpath.nil?
      @path
    end

    # Returns the information from <tt>svnlook changed</tt>.
    def changed
      @changed ||= look_at('changed')
    end

    # Yields all directories above a changed trunk, branches or tags directory.
    #
    # Assuming a project layout like this:
    #
    #   [root]
    #   |- project1
    #   |- project2
    #   |- group1
    #     `- project3
    #       |- branches
    #       |- tags
    #       `- trunk
    #
    # Then committing to <tt>group1/project3/trunk</tt> will yield both
    # <tt>group1/project3/trunk</tt> and <tt>project3</tt>.
    def changed_projects #:yields: full_path, project_path
      (@dirs_changed ||= look_at('dirs-changed')).split("\n").each do |dir|
        yield dir, $1 if dir =~ /([\w\-\.]+)\/(?:trunk|branches|tags)/
      end
    end

    # Returns the HEAD revision number (<tt>svnlook youngest</tt>)
    def head
      @head ||= look_at('youngest')
    end

    # Returns the author of the last commit.
    def author
      @author ||= get_line_from_info(0)
    end

    # Returns the log message of the last commit.
    def message
      @message ||= get_line_from_info(3)
    end

    # Returns the date from the last commit.
    def date
      @date ||= get_line_from_info(1)
    end

    # Runs an arbitrary +svn+ command and returns its results.
    def exec(command)
      command = "#{@svn_path} #{command} #{Subtrigger.svn_args}"
      `#{command}`
    end

  private

    # Execute a +svnlook+ command for the current repository and revision.
    def look_at(subcommand)
      `#{File.join(File.dirname(@svn_path), 'svnlook')} #{subcommand} #{@path} -r #{@revision}`
    end

    # Get the contents of a line from the <tt>svnlook info</tt> output, which
    # looks like this:
    #
    #   Author name
    #   Commit date
    #   Log message length
    #   Log message
    #
    def get_line_from_info(n)
      @info ||= look_at('info')
      @info.split("\n")[n]
    end
  end
end