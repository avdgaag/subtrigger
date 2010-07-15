require File.join(File.dirname(__FILE__), 'test_helper')

class TestTemplate < Test::Unit::TestCase
  def setup
    @templates = <<-EOS
@@ one
foo
@@ two
bar %s
EOS
    Subtrigger::Template.parse(@templates)
  end

  def test_should_parse_format
    assert_not_nil(Subtrigger::Template.find('one'))
    assert_not_nil(Subtrigger::Template.find('two'))
    assert_nil(Subtrigger::Template.find('three'))
  end

  def test_should_raise_when_unparseable
    assert_raise(Subtrigger::Template::Unparseable) { Subtrigger::Template.parse('foo') }
  end

  def test_should_keep_track_of_created_templates
    assert_instance_of(Subtrigger::Template, Subtrigger::Template.find('one'))
  end

  def test_should_find_template_by_name
    assert_equal('foo', Subtrigger::Template.find('one').string)
  end

  def test_should_convert_to_string
    t = Subtrigger::Template.find('one')
    assert_equal(t.string, t.to_s)
  end

  def test_should_format_template
    t = Subtrigger::Template.find('two')
    assert_equal('bar %s', t.to_s)
    assert_equal('bar baz', t.format('baz'))
  end
end