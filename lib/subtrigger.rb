# Libraries
begin
  require 'pony'
rescue LoadError
  puts 'WARNING: Subtrigger requires Pony to send e-mails.'
end
require 'time'

# Load internals
require 'subtrigger/dsl'
require 'subtrigger/revision'
require 'subtrigger/rule'
require 'subtrigger/template'
require 'subtrigger/path'

module Subtrigger

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
  # executable that used is the first found by {Path#to}.
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
  # @todo unstub by removing return statements
  def svnlook(*args)
    `svnlook #{[*args].join(' ')}`
    return "bram\n2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)\n215\nDescription of log" if [*args].first == 'info'
    return "/project1/trunk\n/project1/branches/rewrite\n" if [*args].first == 'dirs-changed'
  end

  # @see Path#initialize
  # @return [Path] The 'global' Path object
  def path
    @path ||= Path.new
  end

private

  # Override Kernel#` to prefix our commands with the path to subversion
  # @param [String] arg is the command to run
  # @return [String] the command's output
  # @todo maybe build a check to only prefix the path when actually calling
  #  svn or svnlook or something.
  def `(arg)
    puts "Called: " + path.to('svn') + '/' + arg
    # super(path_to('svn') + '/' + arg)
  end

  extend self
end

# Make the DSL available in the top-level domain
include Subtrigger::Dsl

# At the end of the rules file perfrom the actual {Subtrigger#run}
at_exit do
  raise ArgumentError unless ARGV.size == 2
  Subtrigger.run(*ARGV)
end