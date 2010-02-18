require 'helper'

class TestRepository < Test::Unit::TestCase
  should 'not work on non-existant repo' do
    assert_raise(RuntimeError) { Subtrigger::Repository.new('foo', 'bar') }
  end

  context 'for a repository' do
    setup do
      File.stubs(:directory?).returns(true)
      @r = Subtrigger::Repository.new('path/to/repo', 1)
    end

    should 'not work on illegal revision' do
      assert_raise(RuntimeError) { Subtrigger::Repository.new('foo', 'bar') }
    end

    should 'expand path' do
      assert_equal('path/to/repo/foo', @r.path('foo'))
    end

    should 'use svnlook info' do
      @r.expects(:look_at).with('info').returns('Foo')
      assert_equal('Foo', @r.author)
    end

    should 'use custom configuration' do
      Subtrigger::Repository.any_instance.expects(:`).with('/usr/foo/svn info --non-interactive').once
      Subtrigger::Repository.any_instance.expects(:`).with('/usr/foo/svnlook info path/to/repo -r 1 --non-interactive').once.returns('')
      Subtrigger.svn = '/usr/foo/svn'
      Subtrigger.svn_args = '--non-interactive'
      @r = Subtrigger::Repository.new('path/to/repo', 1)
      @r.exec('info')
      @r.author
    end

    should 'yield changed directories' do
      @r.expects(:look_at).with('dirs-changed').returns("www.project1.com/trunk\nsub/www.project2.com/tags/v1")
      yieldings = [
        ['www.project1.com/trunk', 'www.project1.com'],
        ['sub/www.project2.com/tags/v1', 'www.project2.com']
      ]
      i = 0
      @r.changed_projects do |path, project|
        assert_equal(yieldings[i][0], path)
        assert_equal(yieldings[i][1], project)
        i += 1
      end
    end
  end
end