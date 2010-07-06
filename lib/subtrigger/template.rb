module Subtrigger
  # = Template
  #
  # Reads, parses and manages inline templates.
  #
  # When you define string templates at the end of your rules file, this class
  # can parse and keep track of them.
  #
  # @example Defining templates
  #   # at the end of your Ruby file...
  #   __END__
  #   @@ Template 1
  #   Foo
  #   @@ Template 2
  #
  # You simply define a new template using `@@`, followed by a name and then
  # the textual contents.
  #
  # You can read the templates and use them, for example, in e-mails.
  #
  # @example Using templates
  #   Template.parse(__DATA__.read)
  #   Template.find('Template 1') # => 'Foo'
  #
  # @author Arjan van der Gaag
  # @since 0.3.0
  class Template
    # The unique identifier for this template
    attr_reader :name

    # The actual contents of the template
    attr_reader :string

    # List of defined templates the class tracks
    @children = []

    # Parse the contents of a string and extract templates from it. These are
    # tracked so you can use Template#find to retrieve them by name.
    #
    # @param [String] the contents of your rules file's <tt>__DATA__.read</tt>
    def self.parse(string)
      string.split(/^@@ (.*)\n/).map(&:chomp).slice(1..-1).each_slice(2) do |name, content|
        @children << new(name, content)
      end
    end

    # Finds and returns the content of the template by the given name.
    #
    # @param [String] name is the name of the template
    # @return [String] is Template#content
    def self.find(name)
      @children.find { |child|
        child.name == name
      }.content
    end

    def initialize(name, string) #:nodoc:
      @name, @string = name, string
    end
  end
end