require 'helper'

class TestSubtrigger < Test::Unit::TestCase
  context 'with a clean slate' do
    setup do
      Subtrigger.reset
      Subtrigger::Trigger.reset
    end

    should 'output the version number' do
      assert_match(/\d+\.\d+\.\d+/, Subtrigger.version)
    end

    should 'configure with a block' do
      assert_nil Subtrigger.svn
      output = Subtrigger.configure do |c|
        c.svn = 'foo'
      end
      assert_equal('foo', Subtrigger.svn)
      assert_equal(Subtrigger, output)
    end

    should 'Create new Repository object' do
      Subtrigger::Repository.expects(:new).with('foo', '1')
      Subtrigger.run('foo', '1')
    end

    should 'Run all triggers' do
      Subtrigger::Repository.stubs(:new).returns('foo')
      Subtrigger::Trigger.expects(:run).with('foo')
      Subtrigger.run('foo', '1')
    end

    should 'create a new trigger' do
      assert_equal(0, Subtrigger::Trigger.triggers.size)
      Subtrigger.on(/foo/) { |m,r| }
      assert_equal(1, Subtrigger::Trigger.triggers.size)
    end

    should 'chain creation of triggers' do
      assert_equal(Subtrigger, Subtrigger.on(/foo/) { |m,r| })
    end
  end
end