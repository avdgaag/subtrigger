require 'lib/subtrigger/dsl'
require 'lib/subtrigger/revision'
require 'lib/subtrigger/rule'
require 'lib/subtrigger/template'

# @todo Make Dsl's methods available in the top level
# @todo find a way to fire the evaluation process at the end of the file
module Subtrigger

  Exception = Class.new(Exception)

  def version
    File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end

  def run(repository_path, revision_number)
    Template.parse(DATA.read)
    rev = Revision.new(revision_number + "\n" + svnlook('info', repository_path))
    Rule.matching(rev).each { |r| r.run(rev) }
  end

  def svn(*args)
    `svn #{[*args].join(' ')}`
  end

  def svnlook(*args)
    "svnlook #{[*args].join(' ')}"
    "bram\n2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)\n215\nDescription of log"
  end

  extend self
end

include Subtrigger::Dsl

at_exit do
  raise ArgumentError unless ARGV.size == 2
  Subtrigger.run(*ARGV)
end