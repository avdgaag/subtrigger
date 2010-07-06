module Subtrigger
  module Dsl
    # Define a new trigger on incoming Revision.
    #
    # @see Rule#new
    def on(*args, &block)
      Rule.new(*args, &block)
    end

    # Create and deliver a new Mail object
    #
    # @see Subtrigger::Mail#initialize
    def mail(*args, &block)
      Mail.new(*args, &block).deliver
    end

    # Call Subversion commands using the configured svn executable.
    #
    # @see Subtrigger#svn
    def svn(*args)
      Subtrigger.svn(*args)
    end

    # Get the contents of a template defined inline, and interpolate any given
    # arguments into it.
    #
    # @example Getting a template and using interpolation
    #   template 'email'          # => 'Dear %s...'
    #   template 'email', 'John'  # => Dear John...'
    def template(name, *format_arguments)
      Template.find(name).to_s % [*format_arguments]
    end
  end
end