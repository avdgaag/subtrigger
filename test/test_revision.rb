require File.join(File.dirname(__FILE__), 'test_helper')

class TestRevision < Test::Unit::TestCase
  def setup
    @valid_arguments = [
      '6000',
      "john\n2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)\n215\nDescription of log\n",
      '/foo/trunk'
    ]
    @revision = Subtrigger::Revision.new(*@valid_arguments)
  end

  def test_should_require_string_arguments
    assert_raise(ArgumentError) { Subtrigger::Revision.new }
    assert_raise(ArgumentError) { Subtrigger::Revision.new('foo') }
    assert_raise(ArgumentError) { Subtrigger::Revision.new('foo', 'bar') }
    assert_nothing_raised(ArgumentError) { Subtrigger::Revision.new(*@valid_arguments) }
  end

  def test_should_return_author
    assert_equal('john', @revision.author)
  end

  def test_should_return_revision_number
    assert_equal(6000, @revision.number)
  end

  def test_should_return_date
    assert_equal(Time.parse('2010-07-05 17:00:00 +0200 (Mon, 01 Jan 2010)'), @revision.date)
  end

  def test_should_return_message
    assert_equal('Description of log', @revision.message)
  end

  def test_should_raise_when_unparsable
    assert_raise(ArgumentError) { Subtrigger::Revision.new('6000', "invalid info", '') }
  end

  def test_should_return_modified_projects
    assert_equal(['/foo'], @revision.projects)
  end
end
