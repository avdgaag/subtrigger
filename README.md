# Subtrigger

A simple DSL for defining callbacks to be fired as Subversion hooks with
built-in support for inspecting the repository and sending out e-mails.

## Example Usage

This library is intended for use as a Subversion post-commit hook. It allows
you to define callbacks that fire when certain conditions on a revision are
met. Simply require Subtrigger and define your rules:

    require 'subtrigger'

    on /deploy to (\w+)/ do |revision, matches|
      puts "Should deploy to #{matches[:message].first}"
    end

Save this as a file in your Subversion repository, like
`/path/to/repo/hooks/deploy.rb`. Then in your Subversion commit hook
file (`/path/to/repo/hooks/post-commit`) simply call the file using
Ruby:

    /usr/bin/ruby -rubygems /path/to/repo/hooks/deploy.rb "$1" "$2"

You could define triggers to...

* Send out confirmation e-mails to specific developers
* Auto-update a working copy on a production server
* Create a back-up archive
* Whatever else you can do with Ruby…

## Detailed usage

### Matchers

The default usage in the example above uses a regular expression which by
default will be matched against the log message of the revision that
triggers the hook. But you can test both other attributes and with other
objects (basically anything that responds to `#===`).

    # Test on author name
    # You can use `:author`, `:message`, `:date`,
    # `:number`
    on :author => /john|graham|michael|terry/ do
      puts 'Always look on the bright side of life!'
    end

    # Test using a matcher object
    class EvenNumberMatcher
      def ===(revision)
        revision.number % 2 == 0
      end
    end
    on :number => EvenNumberMatcher.new do
      puts 'The revision number is an even number'
    end

### Sending e-mails

Subtrigger uses Pony to enable the sending of e-mails straigt from your
triggers. This means you can send an e-mail when a branch is created, just
to name an example.

    on /confirm via email/ do
      mail :to      => 'me@example.com',
           :from    => 'svn@example.com',
           :subject => 'E-mail confirmation of commit',
           :body    => 'Your commit has been saved.'
    end

### Inline templates

To remove long strings from your templates you can define templates right
in your rules file.

    on /confirm via email/ do |r|
      mail :to      => 'me@example.com',
           :from    => 'svn@example.com',
           :subject => 'E-mail confirmation of commit',
           :body    => template('E-mail confirmation', r.number)
    end
    __END__
    @@ E-mail confirmation
    Your commit (%s) has been saved
    @@ Other template
    ...

This will result in an e-mail like `Your commit (5299) has been
saved`.

### Running the triggers

Note that all triggers are run when your rules file ends (using the global
`at_exit` callback). There's no need to explicitly start this process
yourself.

## Warnings

Note that subversion calls its hooks in an empty environment, so there's
no `$PATH` or anything. Always use full absolute paths. Also, hooks are
notoriously hard to debug, so make sure to write some debugging information
somewhere so you know what is going on.

## Changes

Note that Subtrigger is still in early stages of development.
Until it hits 1.0 there are bound to be major changes.

See HISTORY.md for a detailed changelog.

## Credits

* **Author**: Arjan van der Gaag
* **E-mail**: arjan@arjanvandergaag.nl
* **URL**: [http://avdgaag.github.com/subtrigger][1]
* **Source**: [http://github.com/avdgaag/subtrigger][2]
* **API documentation**: [http://avdgaag.github.com/subtrigger][3]

[1]: http://arjanvandergaag.nl
[2]: http://github.com/avdgaag/subtrigger
[3]: http://avdgaag.github.com/subtrigger

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a
  commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.
