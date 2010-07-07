module Subtrigger
  # The Dsl module provides some nice-looking methods that can be used to
  # perform the most important Subtrigger operations.
  #
  # This is intended to be included in the top-level namespace, so a script
  # can call these functions directly.
  #
  # @author Arjan van der Gaag
  # @since 0.3.0
  module Dsl
    # Define a new trigger on incoming Revision.
    #
    # @see Rule#initialize
    # @return [nil]
    def on(*args, &block)
      Rule.new(*args, &block)
    end

    # Create and deliver a new Mail object using Pony. See its documentation
    # for more information.
    # @return [nil]
    def mail(*args)
      ::Pony.mail(*args)
    end

    # Call Subversion commands using the configured svn executable.
    #
    # @see Subtrigger#svn
    # @return [String] the command's output
    def svn(*args)
      Subtrigger.svn(*args)
    end

    # Get a template defined inline and format it using the given arguments.
    #
    # @see Template#format
    # @return [String] the formatted template
    def template(name, *format_arguments)
      Template.find(name).format [*format_arguments]
    end
  end
end