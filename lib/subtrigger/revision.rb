require 'time'
module Subtrigger
  # = Revision
  #
  # A simple wrapper around the output of Subversion's `svnlook` command.
  #
  # This class will let you make simple queries against the properties of a
  # Subversion revision. It parses its output into keys and values so you can
  # perform operations on them.
  #
  # @example Example raw input
  #   6000
  #   bram
  #   2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)
  #   215
  #   Description of log
  #
  # That is the following attributes on each line:
  #
  # * Revision number
  # * Author
  # * Timestamp
  # * Log message size
  # * Log message
  #
  # This is almost the same as the output of `svnlook info`, with the only
  # difference that the output of `svnlook youngest` is prepended.
  #
  # @example Usage
  #   @revision = Revision.new('...')
  #   @revision.author # => 'john'
  #   @revision.message # => 'Description of log'
  #   @revision.date # => (instance of Time)
  #
  # @author Arjan van der Gaag
  # @since 0.3.0
  class Revision
    # Raised when the given svn output can not be parsed.
    InvalidOutput = Class.new(Exception)

    # The raw output of the svnlook command.
    attr_reader :raw

    # the parsed Hash of attributes for this revision
    attr_reader :attributes

    def initialize(svn_output)
      @raw = svn_output
      @attributes = {}
      parse
    end

    %w{author date message number}.each do |name|
      define_method(name) do
        attributes[name.to_sym]
      end
    end

  private

    # Parses the raw log of svnlook into a Hash of attributes.
    # @todo parse the log info here and raise exception when it doesn't compute
    def parse
      number, author, timestamp, size, message = raw.split("\n", 5)
      attributes[:number] = number.to_i
      attributes[:author] = author
      attributes[:timestamp] = Time.parse(timestamp)
      attributes[:message] = message
    end
  end
end