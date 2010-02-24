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
#   Subtrigger.on(/\[deploy\]/) do |matches, repo|
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
#   Subtrigger::Email.new(:to => "#{repo.author}@company.tld",
#                         :from => 'svn@company.tld',
#                         :subject => 'Trigger notification',
#                         :body => "Dear #{repo.author}, ...")
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
#   Subtrigger.on(/foo/) { |matches, repo|
#     puts "#{repo.author} comitted foo!"
#   }.on(/bar/) { |matches, repo|
#     puts "#{repo.author} comitted bar!"
#   }.run(*ARGV)
#
# === Command Line Usage
#
# There is a command-line tool available for running Subtrigger. It simply
# requires the Subtrigger library and calls +run+. Most of the time, you'll
# want to write your own script and <tt>require 'subtrigger'</tt> yourself.
#
# You can run <tt>subtrigger -v</tt> to see the currently installed version
# of Subtrigger.
#
# === Configuration
#
# Since subversion usually calls its hooks in an empty environment (even
# without a $PATH) you might need to make some settings manually:
#
#   Subtrigger.svn = '/path/to/svn'
#   Subtrigger.sendmail = '/path/to/sendmail'
#   Subtrigger.svn_args = ''
#
# The <tt>svn_args</tt> setting is a string appended to every +svn+ command.
# This allows you to, for example, set a custom username and password. You
# might also want to apply the <tt>--non-interactive</tt> argument. For
# example:
#
#   Subtrigger.svn_args = '--username my_name --password secret --non-interactive'
#
# Make sure your gems are installed and the correct permissions are set. Note
# that Subversion hooks generate no output, so run your hooks manually for
# testing purposes.
module Subtrigger
  attr_accessor :svn, :sendmail, :svn_args

  # Output the version number for this gem by reading /VERSION
  def version
    File.read(File.join(File.dirname(__FILE__), *%w{.. VERSION}))
  end

  # This is the main spark in the program.
  # It runs all available triggers on the repository object created with the
  # two command line arguments: the path to the repository and its revision
  # number.
  #
  # If an exception occurs, the program will quit with its error message.
  def run(*args)
    Trigger.run(Repository.new(*args))
  rescue Exception => e
    puts "Error: #{e}" and exit(1)
  end

  # Define a new +Trigger+ object -- shortcut method to
  # <tt>Trigger#define</tt>. To enable method chaining this method returns
  # itself.
  def on(pattern, &block)
    Trigger.define(pattern, &block)
    self
  end
  extend self
end

require 'subtrigger/email'
require 'subtrigger/trigger'
require 'subtrigger/repository'