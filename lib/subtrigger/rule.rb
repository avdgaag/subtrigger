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

    # The pattern for this rule to match against a Revision#message
    attr_reader :pattern

    # A hash of Revision attributes and regular expressions to match against
    attr_reader :options

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
    # Revision. The required block
    #
    # @param [Regex] pattern is the criterium for the log message.
    # @param [Hash] options defines additional criteria.
    # @yield [revision] the code the run when this rule matches
    # @yieldparam [Revision] revision is the currently matches Revision
    # @option options [Regex] :author  Criterium for Revision#author
    # @option options [Regex] :date    Criterium for Revision#date
    # @option options [Regex] :number  Criterium for Revision#number
    # @option options [Regex] :project Criterium for Revision#project
    def initialize(pattern, options = {}, &block)
      @pattern, @options = pattern, options
      self.define_method(:run, block)
      self.register self
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
      pattern =~ revision.message
      
    end
  end
end