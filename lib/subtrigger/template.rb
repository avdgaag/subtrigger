module Subtrigger
  # Reads, parses and manages inline templates.
  #
  # When you define string templates at the end of your rules file, this class
  # can parse and keep track of them. You can then easily retrieve them again
  # and optionally format it like with <tt>String#%</tt>.
  #
  # You simply define a new template using <tt>@@</tt>, followed by a name and
  # then the textual contents (see the example below).
  #
  # You can read the templates and use them, for example, in e-mails.
  #
  # @example Defining templates
  #   # at the end of your Ruby file:
  #    __END__
  #   @@ Template 1
  #   Foo
  #   @@ Template 2
  #   Hello, %s!
  #
  # @example Parsing templates
  #   Template.parse(__DATA__.read)
  #
  # @example Using templates
  #   Template.find('Template 1') # => 'Foo'
  #
  # @example Formatting templates
  #   Template.find('Template 2') # => 'Hello, %s!'
  #   Template.find('Template 2').format('world') # => 'Hello, world!'
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

    # The pattern that separates one template from another
    TEMPLATE_DELIMITER = /^@@ (.*)\n/

    # Exception raised when a string cannot be parsed into templates,
    # because the delimiter cannot be found
    Unparseable = Class.new(Exception)

    # Parse the contents of a string and extract templates from it. These are
    # tracked so you can use {Template#find} to retrieve them by name.
    #
    # @param [String] the contents of your rules file's <tt>__DATA__.read</tt>
    # @return [nil]
    def self.parse(string)
      raise Unparseable, "Could not split into templates: #{string.inspect}" unless string =~ TEMPLATE_DELIMITER
      string.split(TEMPLATE_DELIMITER).map(&:chomp).slice(1..-1).each_slice(2) do |name, content|
        @children << new(name, content)
      end
      nil
    end

    # Finds and returns the content of the template by the given name.
    #
    # @param [String] name is the name of the template
    # @return [String] is Template#content
    def self.find(name)
      @children.find { |child|
        child.name == name
      }
    end

    # Convert to string using the textual contents of the template
    # @return [String]
    def to_s
      string
    end

    # Get the contents of the template and interpolate any given
    # arguments into it.
    #
    # @example Getting a template and using interpolation
    #   template.to_s           # => 'Dear %s...'
    #   template.format 'John'  # => 'Dear John...'
    # @return [String] the formatted template contents
    def format(*args)
      to_s % [*args]
    end

    # @param [String] name is the unique identifier of a template
    # @param [String] string is the contents of the template.
    def initialize(name, string)
      @name, @string = name, string
    end
  end
end