module Subtrigger
  # A simple wrapper around the output of Subversion's <tt>svnlook</tt>
  # command.
  #
  # This class will let you make simple queries against the properties of a
  # Subversion revision. It parses its output into keys and values so you can
  # perform operations on them.
  #
  # == Attributes
  #
  # It knows about the following attributes:
  #
  # * Revision number
  # * Author
  # * Timestamp
  # * Log message
  # * changed directories
  #
  # This works by passing in the number of the revision to use, the raw
  # output of <tt>svnlook info</tt> and the raw output of
  # <tt>svnlook dirs-changed</tt>.
  #
  # == Special attributes
  #
  # Revision knows about changed projects. This is extracted from the list
  # of changed directories. A project is a directory that is directly above
  # a directory named <tt>trunk</tt>, <tt>branches</tt> or <tt>tags</tt>. So
  # when a directory <tt>/internal/accounting/trunk</tt> is changed, the
  # project <tt>/internal/accounting</tt> is reported.
  #
  # @example Example of raw input for <tt>info</tt>
  #   john
  #   2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)
  #   215
  #   Description of log
  #
  # @example Usage
  #   @revision = Revision.new('...')
  #   @revision.author    # => 'john'
  #   @revision.message   # => 'Description of log'
  #   @revision.date      # => (instance of Time)
  #   @revision.projects  # => ['/project1', 'project2', ...]
  #
  # @author Arjan van der Gaag
  # @since 0.3.0
  class Revision
    # The raw output of the svnlook command.
    attr_reader :raw

    # A list of all directories that were changed in this revision
    attr_reader :dirs_changed

    # the parsed Hash of attributes for this revision
    attr_reader :attributes

    def initialize(revision_number, info, dirs_changed)
      @attributes = { :number => revision_number.to_i }
      @raw = info
      @dirs_changed = dirs_changed.split
      parse
    end

    %w{author date message number}.each do |name|
      define_method(name) do
        attributes[name.to_sym]
      end
    end

    # Creates a list of directory paths in the repository that have changes
    # and contain a <tt>trunk</tt>, <tt>branches</tt> or <tt>tags</tt>
    # directory.
    #
    # For example, a changed path in like <tt>/topdir/project_name/trunk</tt>
    # would result in <tt>/topdir/project_name</tt>.
    #
    # @return [Array<String>] list of changed project paths
    def projects
      pattern = /\/(trunk|branches|tags)/
      dirs_changed.grep(pattern).map do |dir|
        dir.split(pattern, 2).first
      end.uniq
    end

  private

    # Parses the raw log of svnlook into a Hash of attributes.
    def parse
      raise ArgumentError, 'Could not parse Subversion info: expected at least 4 lines' if raw.split("\n").size < 4
      author, timestamp, size, message = raw.split("\n", 4)
      attributes[:author] = author
      attributes[:date] = Time.parse(timestamp)
      attributes[:message] = message.chomp
    end
  end
end