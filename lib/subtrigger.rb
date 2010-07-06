require 'lib/subtrigger/dsl'
require 'lib/subtrigger/revision'
require 'lib/subtrigger/rule'
require 'lib/subtrigger/template'
require 'lib/subtrigger/mail'

module Subtrigger

  # A list of absolute paths on te filesystems to where the svn executables
  # might be located. These are scanned in order to find the svn executable
  # to use.
  POSSIBLE_PATHS = %w{/opt/subversion/bin /usr/sbin /usr/bin}

  # Standard exception for all Subtrigger exceptions
  Exception = Class.new(Exception)

  # Return the current version number as defined in ./VERSION
  # @return [String] version number (e.g. '0.3.1')
  def version
    File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end

  # Run the current file of rules.
  #
  # This method is called after all the rules have been defined. It takes
  # the command line arguments that come from subversion.
  #
  # @param [String] repository_path is the path to the repository to query
  # @param [String] revision_number is the revision number that triggered the
  #   hook.
  # @return nil
  def run(repository_path, revision_number)
    Template.parse(DATA.read)
    rev = Revision.new(
      revision_number,
      svnlook('info', repository_path),
      svnlook('dirs-changed', repository_path)
    )
    Rule.matching(rev).each { |r| r.run(rev) }
  end

  # Make a system call to <tt>svn</tt> with the given arguments. The
  # executable that used is the first found in <tt>POSSIBLE_PATHS</tt>.
  #
  # @example Using multiple arguments
  #   svn 'update', 'foo', '--ignore-externals'
  #   # => '/usr/bin/svn update foo --ignore-externals'
  # @return [String] output from the command
  def svn(*args)
    `svn #{[*args].join(' ')}`
  end

  # Make a system call to <tt>svnlook</tt> with the given arguments. The
  # executable # that used is the first found in
  # <tt>POSSIBLE_PATHS</tt>.
  #
  # @example Using multiple arguments
  #   svnlook 'youngest', '/path/to/repo'
  #   # => '/usr/bin/svnlook youngest /path/to/repo
  # @return [String] output from the command
  def svnlook(*args)
    `svnlook #{[*args].join(' ')}`
    return "bram\n2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)\n215\nDescription of log" if [*args].first == 'info'
    return "/project1/trunk\n/project1/branches/rewrite\n" if [*args].first == 'dirs-changed'
  end

  # Find the correct path to the svn executable. We look at the list of
  # possible locations in <tt>POSSIBLE_PATHS_TO_SVN</tt> see where an
  # executable file exists.
  #
  # Note: this probably only works on unix-like systems.
  #
  # @todo: implement memoization per argument
  def path_to(program)
    POSSIBLE_PATHS.find { |path| system('test -x' + path + '/' + program) }
  end

private

  # Override Kernel#` to prefix our commands with the path to subversion
  # @todo: maybe build a check to only prefix the path when actually calling
  #  svn or svnlook or something.
  def `(arg)
    # super(path_to('svn') + '/' + arg)
  end

  extend self
end

include Subtrigger::Dsl

at_exit do
  raise ArgumentError unless ARGV.size == 2
  Subtrigger.run(*ARGV)
end