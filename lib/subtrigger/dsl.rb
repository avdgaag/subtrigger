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
    # @todo implement
    def mail(from, to, message)

    end

    # Call Subversion commands using the configured svn executable.
    #
    # @todo implement
    def svn(*args)

    end

  end
end