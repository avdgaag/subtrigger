class Dsl
  def templates
    @output ||= begin
      parts = DATA.read.split(/^@@ (.+)\s*$\n/)[1..-1]
      output = {}
      parts.each_index do |i|
        output[parts[i]] = parts[i+1] if i % 2 == 0
      end
      output
    end
  end

  def on(&block)

  end
end

# on /bla/ do
#
# end
#
# on /notify (.+?)/ do |matches|
#   mail to, from,
# end
__END__
@@ template 1
Hello, world!
@@ template 2
foo, bar, baz