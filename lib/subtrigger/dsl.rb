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
      puts "Sending mail from #{from} to #{to} with #{message}"
    end

    # Call Subversion commands using the configured svn executable.
    #
    # @todo implement
    def svn(*args)
      puts "Calling 'svn #{[*args].join(' ')}'"
    end

    def template(name, *format_arguments)
      Template.find(name).to_s % [*format_arguments]
    end
  end
end