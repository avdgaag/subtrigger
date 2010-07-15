require File.join(File.dirname(__FILE__), 'test_helper')

class CustomMatcher
  def initialize
    @matched = false
  end

  def ===(other)
    @matched = (other.number == 6000)
  end

  def matched?
    @matched
  end
end

class TestRule < Test::Unit::TestCase
  def setup
    Subtrigger::Rule.reset
    @rule1 = Subtrigger::Rule.new(/foo/) { }
    @rule2 = Subtrigger::Rule.new(/bar/) { }

    # Set up dummy Revision
    Struct.new('Revision', :message, :number)
    @revision = Struct::Revision.new('foo', 6000)
  end

  def test_should_keep_track_of_created_classes
    assert_equal(2, Subtrigger::Rule.rules.size)
  end

  def test_should_return_all_matching_classes
    assert_equal(1, Subtrigger::Rule.matching(@revision).size)
  end

  def test_should_return_empty_array_when_none_match
    assert_instance_of(Array, Subtrigger::Rule.matching(Struct::Revision.new('bar', 6000)))
  end

  def test_should_raise_without_block
    assert_raise(ArgumentError) { Subtrigger::Rule.new(/foo/) }
  end

  def test_should_match_object
    assert @rule1.matches?(@revision)
  end

  def test_should_call_block_with_revision_on_run
    Subtrigger::Rule.new(/foo/) { |r, m|
      assert_equal(@revision, r)
    }.run(@revision)
  end

  def test_should_pass_on_all_captures_to_block
    Subtrigger::Rule.new(/fo(o)?/) { |r, m|
      assert_equal({:message => ['o']}, m)
    }.run(@revision)
  end

  def test_should_use_custom_matcher_for_revision
    matcher = CustomMatcher.new
    Subtrigger::Rule.new(:all => matcher) { }
    Subtrigger::Rule.matching(@revision)
    assert matcher.matched?
  end
end