require File.join(File.dirname(__FILE__), 'test_helper')

class TestPath < Test::Unit::TestCase
  def setup
    @path = Subtrigger::Path.new
  end

  def stub_system
    @path.class.send(:define_method, :system) do |command|
      yield command
    end
  end

  def test_should_find_program_in_default_path
    stub_system { |c| c =~ /usr\/bin/ }
    assert_equal('/usr/bin', @path.to('foo'))
  end

  def test_should_find_first_match
    stub_system { true }
    puts @path.locations
    assert_equal('/opt/subversion/bin', @path.to('foo'))
  end

  def test_should_raise_exception_when_not_found
    stub_system { false }
    assert_raise(Subtrigger::Path::NotFound) { @path.to('foo') }
  end

  def test_should_add_path_to_stack
    stub_system { true }
    @path << '/bar'
    assert_equal('/bar', @path.to('baz'))
  end

  def test_should_memoize_lookup
    i = 0
    stub_system { |c| i += 1; c = /usr\/bin/ }
    @path.to('foo')
    @path.to('foo')
    assert_equal(1, i)
  end

  def test_should_memoize_lookup_per_argument
    i = 0
    stub_system { |c| i += 1; c = /usr\/bin/ }
    @path.to('foo')
    @path.to('bar')
    assert_equal(2, i)
  end
end