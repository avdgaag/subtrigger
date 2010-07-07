module Subtrigger
  # Our own little implementation of the path, allowing us to look up
  # the location of executable files. This is because Subversion hooks
  # run in a clean environment, without any environment variables such as
  # $PATH. We therefore need to run (for example) <tt>/usr/bin/svn update</tt>
  # rather than <tt>svn update</tt>.
  #
  # There is a list of default locations that will be searched, but you
  # may add your own if you want to. This is useful if you've got a custom
  # installation on your machine you want to use.
  #
  # Note: testing whether an executable exists in a given path is done using
  # the unix program <tt>test</tt>, which will most likely not work on
  # windows machines (untested).
  #
  # @example Getting the path to an executable
  #   Path.new.to('svn') #=> '/usr/bin'
  #
  # @example Adding a preferred location
  #   path = Path.new
  #   path << '/opt/local'
  #   path.to('svn') => '/opt/local'
  #
  # @author Arjan van der Gaag
  # @since 0.3.0
  class Path

    # The default list of paths to look in, covering most of the use cases.
    DEFAULT_PATHS = %w{/opt/subversion/bin /usr/sbin /usr/bin}

    # A list of absolute paths on te filesystems to where the svn executables
    # might be located. These are scanned in order to find the executables
    # to use.
    attr_reader :locations

    # Start a new list of paths, starting with the <tt>DEFAULT_PATHS</tt>
    def initialize
      @locations = DEFAULT_PATHS
      @exists ||= Hash.new do |hash, p|
        hash[p] = system('test -x ' + p)
      end
    end

    # Add a new path to the stack before the existing ones.
    #
    # @param [String] new_path is a new possible location of executables
    # @return [Array] the total list of paths
    def <<(new_path)
      locations.unshift(new_path)
    end

    # Scan all the known paths to find the given program.
    #
    # Note: this probably only works on unix-like systems.
    #
    # @todo: implement memoization per argument
    # @param [String] program is the name of the executable to find, like
    #  <tt>svn</tt>
    # @return [String, nil] the correct path to this program or nil
    def to(program)
      locations.find { |path| exists? File.join(path, program) }
    end

  private

    # Make the actual test if a given path points to an executable file.
    #
    # @param [String] path is the absolute path to test
    # @return [Boolean] whether the path is an executable file
    def exists?(path)
      @exists[path]
    end
  end
end