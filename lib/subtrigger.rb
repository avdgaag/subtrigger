# @todo Make Dsl's methods available in the top level
# @todo find a way to fire the evaluation process at the end of the file
module Subtrigger

  Exception = Class.new(Exception)

  def self.version
    File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')
  end
end