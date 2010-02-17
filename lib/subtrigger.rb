$:.unshift File.dirname(__FILE__)

# = Subtrigger
#
# Subtrigger is a tiny tool for firing callback methods based on triggers in
# subversion log messages.
#
# == Example
#
# When somebody makes a commit:
#
#   r5410 "Added a sitemap to the website [deploy]"
#   A  /www.website.tld/trunk/sitemap.xml
#
# ...then you can trigger the deployment of that project to a staging server
# using a +Trigger+:
#
#   Subtrigger.define_trigger(/\[deploy\]/) do |matches, repo|
#     # do some smart stuff here
#   end
#
# Your trigger has access to the captured groups in its regular expression
# matcher, and to all the <tt>svnlook</tt> information from the repository
# at the revision that fired the hook. This gives you access to changed paths,
# its author, date, etc.
#
# == E-mail notifications
#
# Subtrigger allows you to send notification e-mails to developers:
#
#   # in your trigger:
#   Subtrigger::Email.new("#{repo.author}@company.tld",
#                         'svn@company.tld',
#                         'Trigger notification',
#                         "Dear #{repo.author}, ...")
#
# == Usage
#
# This library is intended to be used as a Subversion post-commit hook.
# The best way to use it to create a post-commit hook file that requires this
# library, sets up one or more triggers and than fires the processing.
#
# Here's an example:
#
#   #!/usr/local/bin/ruby
#   require 'rubygems'
#   require 'subtrigger'
#   Subtrigger.define_trigger(/foo/) do |matches, repo|
#     puts "#{repo.author} comitted foo!"
#   end
#   Subtrigger.run(*ARGV)
#
# Make sure your gems are installed and the correct permissions are set. Note
# that Subversion runs its hooks in an empty environment, with no PATH set,
# and you will also see no output.
module Subtrigger
  # Output the version number for this gem by reading /VERSION
  def self.version
    File.read(File.join(File.dirname(__FILE__), *%w{.. VERSION}))
  end

  # This is the main spark in the program.
  # It runs all available triggers on the repository object created with the
  # two command line arguments: the path to the repository and its revision
  # number.
  #
  # If an exception occurs, the program will quit with its error message.
  def self.run(*args)
    Trigger.run(Repository.new(*args))
  rescue Exception => e
    puts "Error: #{e}" and exit(1)
  end

  # Define a new +Trigger+ object -- shortcut method to <tt>Trigger#define</tt>
  def self.define_trigger(pattern, &block)
    Trigger.define(pattern, &block)
  end
end

require 'subtrigger/email'
require 'subtrigger/trigger'
require 'subtrigger/repository'