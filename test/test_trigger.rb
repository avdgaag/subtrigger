require 'helper'

class TestTrigger < Test::Unit::TestCase
  context 'in a clean state' do
    setup do
      Subtrigger::Trigger.reset
    end

    should 'define a new trigger' do
      Subtrigger::Trigger.define(/foo/) { |m, r| raise 'bar' }
      assert_equal(1, Subtrigger::Trigger.triggers.size)
    end

    should 'apply all triggers' do
      i = 0
      Subtrigger::Trigger.define(/foo/) { |m,r| i += 1 }
      Subtrigger::Trigger.define(/o+/) { |m,r| i += 1 }
      Subtrigger::Trigger.run(stub(:message => 'foo bar'))
      assert_equal(2, i)
    end

    should 'ignore unmatching triggers' do
      i = 0
      Subtrigger::Trigger.define(/foo/) { |m,r| i += 1 }
      Subtrigger::Trigger.define(/x+/) { |m,r| i += 1 }
      Subtrigger::Trigger.run(stub(:message => 'foo bar'))
      assert_equal(1, i)
    end

    should 'empty list of triggers' do
      Subtrigger::Trigger.define(/foo/) { |m,r| }
      assert_equal(1, Subtrigger::Trigger.triggers.size)
      Subtrigger::Trigger.reset
      assert_equal(0, Subtrigger::Trigger.triggers.size)
    end
  end
end