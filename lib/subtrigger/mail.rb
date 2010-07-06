module Subtrigger
  class Mail
    attr_accessor :from, :to, :subject, :body

    # @overload initialize(from, to, subject, message)
    #  @param [String] from the e-mail address to send from
    #  @param [String] to the e-mail address to send to
    #  @param [String] subject the subject line of the message
    #  @param [String] body the contents of the message
    def initialize(*args, &block)
      if args.size == 4
        @from, @to, @subject, @body = *args
      elsif args.size == 0
        instance_eval(&block)
      else
        raise ArgumentError, 'Expected 4 arguments (from, to, subject, body)'
      end
    end

    # @todo: remove development barrier and test real implementation
    def deliver
      sendmail = Subtrigger.path_to('sendmail')
      puts "Using #{sendmail + '/sendmail'} for sending email"
      message = [header, body].join("\n")
      puts "Email sent:", message
      return
      fd = open('|#{sendmail} #{to}', 'w')
      fd.print(message)
      fd.close
      message
    end

    %w{from to subject body}.each do |name|
      define_method(name) do |*args|
        send("#{name}=".to_sym, args.first) unless args.empty?
        instance_variable_get("@#{name}")
      end
    end

  private

    def header
      <<-EOS
To: #{to}
From: #{from}
Subject: [svn] #{subject}
MIME-version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
EOS
    end
  end
end