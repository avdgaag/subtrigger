module Subtrigger
  # A <tt>Rule</tt> object knows when to fire some kind of action for some
  # kind of revision. When the Subversion hook is fired, a Rule can inspect it
  # and choose whether or not to fire its trigger (a piece code defined by the
  # user).
  #
  # In the first example, the rule will output <tt>fired</tt> whenever a
  # <tt>Revision</tt> comes along with a message containing <tt>foo</tt>.
  #
  # In the second example, we find all applicable rules for a given
  # <tt>Revision</tt> object. We can then run each of them.
  #
  # @example 1: Define a simple Rule
  #   Rule.new(/foo/) { puts 'fired' }
  #
  # @example 2: Finding and firing Rules
  #   rev = Revision.new
  #   Rule.matching(rev).map { |rule| rule.run(rev) }
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
    # @return [Array<Rule>] the total list of children
    def self.register(child)
      @rules << child
    end

  public

    # Return an array of all rules currently defined.
    #
    # @return [Array<Rule>]
    def self.rules
      @rules
    end

    # Reset the list of known rules, deleting all currently known rules.
    #
    # @return nil
    def self.reset
      @rules = []
    end

    # Return an array of all existing Rule objects that match the given
    # revision.
    #
    # @param [Revision] revision is the revision to compare rules to.
    # @return [Array<Rule>] list of all matching rules
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
    # @overload initialize(options, &block)
    #   Define a rule with various criteria in a hash.
    #   @param [Hash] options defines matching criteria.
    #   @option options :author  Criterium for Revision#author
    #   @option options :date    Criterium for Revision#date
    #   @option options :number  Criterium for Revision#number
    #   @option options :project Criterium for Revision#project
    def initialize(pattern_or_options, &block)
      raise ArgumentError, 'a Rule requires a block' unless block_given?

      # If not given a hash, we build a hash defaulting on message
      unless pattern_or_options.is_a?(Hash)
        pattern_or_options = { :message => pattern_or_options }
      end

      @criteria, @block = pattern_or_options, block
      @criteria.inspect
      self.class.register self
    end

    # Call this Rule's callback method with the give Revision object.
    # @return [nil]
    def run(rev)
      @rev = rev
      block.call(@rev, collect_captures)
    end

    # Use {Rule#matches?} to see if this <tt>Rule</tt> matches the given
    # <tt>Revision</tt>.
    #
    # @param [Object] the object to compare to
    # @return [Boolean]
    # @see Rule#matches?
    def ===(other)
      matches?(other)
    rescue CannotCompare
      super
    end

    # See if the current rule matches a given subversion revision.
    #
    # @param [Revision] revision the Revision object to compare to.
    # @return [Boolean]
    # @see Rule#===
    # @raise Subtrigger::Rule::CannotCompare when comparing to something other
    #   than a revision.
    def matches?(revision)
      raise CannotCompare unless @criteria.keys.all? { |k| k == :all || revision.respond_to?(k) }
      match = @criteria.any?
      @criteria.each_pair do |key, value|
        if key == :all
          match = (value === revision)
        else
          match &= (value === revision.send(key.to_sym))
        end
      end
      match
    end

  private

    # When using regular expressions to match against string values, we
    # want to be able to get to any captured groups. This method scans all
    # string values with their Regex matchers and collects all captured
    # groups into a namespaced hash.
    #
    # @example
    #   Rule.new /hello, (.+)!/ do |revision, matches|
    #     puts matches.inspect
    #   end
    #   # => { :message => ['world'] }
    #
    # @return [Hash] all captured groups per Revision attribute tested
    # @todo this only passes on capture groups, not the entire match
    def collect_captures
      criteria.inject({}) do |output, (key, value)|
        next if key == :all
        output[key] = @rev.send(key.to_sym).scan(value).flatten if value.is_a?(Regexp)
        output
      end
    end
  end
end