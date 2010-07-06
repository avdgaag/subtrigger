require 'lib/subtrigger'

class BramMatcher
  def ===(attribute)
    attribute.author == 'bram'
  end
end

on /Description/ do
  puts 'Rule 1'
end

on :all => BramMatcher.new do |r, m|
  puts 'Rule 2: ' + r.projects.join(', ')
end

on /De(s|k)cr(.+)/ do |r, matches|
  puts 'Rule 3: ' + matches.inspect
  mail  :from    => 'foo',
        :to      => 'bar',
        :subject => 'subject',
        :body    => template('template 1', matches[:message][1])
end
__END__
@@ template 1
Hello, %s!
@@ template 2
foo, bar, baz