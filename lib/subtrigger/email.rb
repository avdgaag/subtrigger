module Subtrigger
  # = E-mail notifications
  #
  # Sometimes you want to send notification e-mails after the hook has fired
  # to inform developers or yourself of some event. This class is a simple
  # wrapper around the standard +sendmail+ program.
  #
  # == Usage example
  #
  #   Email.new('john@cleese.com', # from
  #             'eric@idle.com',   # to
  #             'Fired',           # subject
  #             'Your post-commit hook has just fired').send
  #
  # If +sendmail+ can not be found on your system an exception will be raised.
  #--
  # TODO: Use a hash of options rather than plain arguments.
  class Email
    attr_accessor :from, :to, :subject, :body

    # Sets up a new message and tries to find +sendmail+ on your system.
    def initialize(to, from, subject, body)
      @to, @from, @subject, @body = to, from, subject, body
      @sendmail = `which sendmail`.strip
      raise 'Could not find sendmail; aborting.' if @sendmail.nil?
    end

    # Tries to use +sendmail+ to send the message.
    def send
      fd = open("|#{@sendmail} #{@to}", "w")
      fd.print(header + "\n" + body)
      fd.close
    end

  private

    def header
      <<-EOS
To: #{@to}
From: #{@from}
Subject: [svn] #{@subject}
MIME-version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
EOS
    end
  end
end