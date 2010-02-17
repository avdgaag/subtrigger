module Subtrigger
  # = Call blocks on a matching pattern
  #
  # This is a framework for combining pairs of matchers and callbacks to run
  # on a commit message. You can define a trigger which this class will
  # apply to a log message.
  #
  # == Example usage
  #
  #   Trigger.define(/foo/) do |matches, repo|
  #     puts "Someone used 'foo' in his commit message"
  #   end
  #
  # When the above trigger is defined and somebody makes a commit message
  # containing +foo+ the block will be called. +matches+ contains any
  # captured regular expression groups, +repo+ is a +Repository+ object for
  # the current repository revision.
  #
  # You can define as many triggers as you like. When no triggers are found
  # an exception will be raised. When no trigger applies, it will quit
  # silently.
  class Trigger
    class << self
      @triggers = {}

      # Run all available triggers on the given Repository object.
      def run(repo)
        raise 'No suitable triggers found.' if @triggers.nil?
        @triggers.each_pair do |pattern, block|
          new(pattern, repo, &block)
        end
      end

      # Create a new Trigger object and add it to the stack.
      def define(pattern, &block)
        (@triggers ||= {})[pattern] = block;
      end
    end

    def initialize(pattern, repo, &block)
      @pattern, @repo, @callback = pattern, repo, block
      parse
    end

  private

    # Scan the commit message and fire the callback if it matches.
    def parse
      @repo.message.scan(@pattern) { |match| @callback.call(match, @repo) }
    end
  end
end