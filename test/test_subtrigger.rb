require 'helper'

class TestSubtrigger < Test::Unit::TestCase
  should 'output the version number' do
    assert_match(/\d+\.\d+\.\d+/, Subtrigger.version)
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
end