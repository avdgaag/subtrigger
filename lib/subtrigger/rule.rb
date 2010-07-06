 module Subtrigger
  # = Rule
  #
  # A rule object knows when to fire some kind of action for some kind of
  # revision. When the Subversion hook is fired, a Rule can inspect it and
  # choose whether or not to fire its trigger (a piece code defined by the
  # user).
  #
  # == Examples
  #
  # @example Define a simple Rule
  #   Rule.new(/foo/) { puts 'fired' }
  #
  # In the above example, this rule will output 'fired' whenever a Revision
  # comes along with a message containing 'foo'.
  #
  # @example Finding and firing Rules
  #   rev = Revision.new
  #   Rule.matching(rev).map { |rule| rule.run(rev) }
  #
  # In this example, we find all applicable rules for a given Revision object.
  # We can then run every single on of them.
  #
  # @since 0.3.0
  # @author Arjan van der Gaag
  class Rule

    # Exception for when trying to apply a rule to something other than an
    # instance of Revision.
    CannotCompare = Class.new(Exception)

    # A hash of Revision attributes and regular expressions to match against
    attr_reader :criteria

    # The callback to run on a match
    attr_reader :block

  private

    @rules = []

    # Keep track of Rule objects that are created in a class instance variable
    #
    # @param [Rule] child is the new Rule object
    def self.register(child)
      @rules << child
    end

  public

    # Return an array of all existing Rule objects that match the given
    # revision.
    #
    # @param [Revision] revision is the revision to compare rules to.
    # @return [Array] list of all matching rules
    def self.matching(revision)
      @rules.select { |child| child === revision }
    end

    # Create a new Rule object with criteria for different properties of a
    # Revision. The required block defines the callback to run. It will have
    # the current Revision object yielded to it.
    #
    # Criteria are Ruby objects that should match (`===`) a Revision's
    # attributes. These would usually be regular expressions, but they
    # can be strings or custom objects if you want to.
    #
    # @overload initialize(pattern, &block)
    #   Define a rule with a pattern matching the log message
    #   @param [Regex] pattern is the regular expression to match against
    #     the revision's log message
    #   @yield [revision] the code the run when this rule matches
    #   @yieldparam [Revision] revision is the currently matches Revision
    # @overload initialize(options, &block)
    #   Define a rule with various criteria in a hash.
    #   @param [Hash] options defines matching criteria.
    #   @option options :author  Criterium for Revision#author
    #   @option options :date    Criterium for Revision#date
    #   @option options :number  Criterium for Revision#number
    #   @option options :project Criterium for Revision#project
    #   @yield [revision] the code the run when this rule matches
    #   @yieldparam [Revision] revision is the currently matches Revision
    def initialize(pattern_or_options, &block)
      # If not given a hash, we build a hash defaulting on message
      unless pattern_or_options.is_a?(Hash)
        pattern_or_options = { :message => pattern_or_options }
      end
      @criteria, @block = pattern_or_options, block
      self.class.register self
    end

    # Call this Rule's callback method with the give Revision object.
    def run(rev)
      block.call(rev)
    end

    def ===(other) #:nodoc:
      if other.kind_of? Revision
        matches? other
      end
    end

    # See if the current rule matches a given subversion revision.
    #
    # @param [Revision] revision the Revision object to compare to.
    # @return [Boolean]
    # @see #===
    # @raise Subtrigger::Rule::CannotCompare when comparing to something other
    #   than a revision.
    def matches?(revision)
      match = true
      criteria.each_pair do |key, value|
        match &= (value === revision.send(key.to_sym))
      end
      match
    end
  end
end