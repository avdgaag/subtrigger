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

# = Introduction
#
# A simple DSL for defining callbacks to be fired as Subversion hooks with
# built-in support for inspecting the repository and sending out e-mails.
#
# = Usage
#
# This library is intended for use as a Subversion post-commit hook. It allows
# you to define callbacks that fire when certain conditions on a revision are
# met. Simply require Subtrigger and define your rules:
#
#   require 'subtrigger'
#
#   on /deploy to (\w+)/ do |revision, matches|
#     puts "Should deploy to #{matches[:message].first}"
#   end
#
# Save this as a file in your Subversion repository, like
# <tt>/path/to/repo/hooks/deploy.rb</tt>. Then in your Subversion commit hook
# file (<tt>/path/to/repo/hooks/post-commit</tt>) simply call the file using
# Ruby:
#
#   /usr/bin/ruby -rubygems /path/to/repo/hooks/deploy.rb "$1" "$2"
#
# = Detailed usage
#
# == Matchers
#
# The default usage in the example above uses a regular expression which by
# default will be matched against the log message of the revision that
# triggers the hook. But you can test both other attributes and with other
# objects (basically anything that responds to <tt>#===</tt>).
#
#   # Test on author name
#   # You can use <tt>:author</tt>, <tt>:message</tt>, <tt>:date</tt>,
#   # <tt>:number</tt>
#   on :author => /john|graham|michael|terry/ do
#     puts 'Always look on the bright side of life!'
#   end
#
#   # Test using a matcher object
#   class EvenNumberMatcher
#     def ===(revision)
#       revision.number % 2 == 0
#     end
#   end
#   on :number => EvenNumberMatcher.new do
#     puts 'The revision number is an even number'
#   end
#
# == Sending e-mails
#
# Subtrigger uses Pony to enable the sending of e-mails straigt from your
# triggers. This means you can send an e-mail when a branch is created, just
# to name an example.
#
#   on /confirm via email/ do
#     mail :to      => 'me@example.com',
#          :from    => 'svn@example.com',
#          :subject => 'E-mail confirmation of commit',
#          :body    => 'Your commit has been saved.'
#   end
#
# == Inline templates
#
# To remove long strings from your templates you can define templates right
# in your rules file.
#
#   on /confirm via email/ do |r|
#     mail :to      => 'me@example.com',
#          :from    => 'svn@example.com',
#          :subject => 'E-mail confirmation of commit',
#          :body    => template('E-mail confirmation', r.number)
#   end
#   __END__
#   @@ E-mail confirmation
#   Your commit (%s) has been saved
#   @@ Other template
#   ...
#
# This will result in an e-mail like <tt>Your commit (5299) has been
# saved</tt>.
#
# = Warnings
#
# Note that subversion calls its hooks in an empty environment, so there's
# no $PATH or anything. Always use full absolute paths. Also, hooks are
# notoriously hard to debug, so make sure to write some debugging information
# somewhere so you know what is going on.
#
# = Credits
#
# Author:: Arjan van der Gaag
# E-mail:: arjan@arjanvandergaag.nl
# URL:: http://arjanvandergaag.nl
# Source:: http://github.com/avdgaag/subtrigger
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
  # @todo: maybe build a check to only prefix the path when actually calling
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