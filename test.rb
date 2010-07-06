require 'lib/subtrigger'

class BramMatcher
  def ===(attribute)
    attribute == 'bram'
  end
end

on /Description/ do
  puts 'test'
end

on :author => BramMatcher.new do |r|
  puts r.message
end

on /notify (.+?)/ do |matches|
  mail to, from
end
__END__
@@ template 1
Hello, world!
@@ template 2
foo, bar, baz