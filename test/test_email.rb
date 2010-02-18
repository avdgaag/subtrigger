require 'helper'

class TestEmail < Test::Unit::TestCase
  context 'with attributes' do
    setup do
      @email = Subtrigger::Email.new(
        :to => 'to@to.com',
        :from => 'from@from.com',
        :subject => 'subject',
        :body => 'body',
        :development => true
      )
      @message = @email.send
    end

    should 'use custom sendmail location' do
      Subtrigger.sendmail = 'foo'
      assert_equal('foo', Subtrigger::Email.new.sendmail)
    end

    should 'set all e-mail attributes' do
      assert_equal('from@from.com', @email.from)
      assert_equal('to@to.com', @email.to)
      assert_equal('subject', @email.subject)
      assert_equal('body', @email.body)
    end

    should 'use to address' do
      assert_match(/From: from@from.com/, @message)
    end

    should 'use from address' do
      assert_match(/To: to@to.com/, @message)
    end

    should 'use subject' do
      assert_match(/Subject: \[svn\] subject/, @message)
    end

    should 'use message body' do
      assert_match(/body/, @message)
    end
  end
end