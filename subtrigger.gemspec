# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{subtrigger}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Arjan van der Gaag"]
  s.date = %q{2010-07-16}
  s.description = %q{This gem allows you to create simple Ruby triggers for Subversion commit messages, responding to keywords in your log messages to send e-mails, deploy sites or do whatever you need.}
  s.email = %q{arjan@arjanvandergaag.nl}
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "README.md",
     "Rakefile",
     "VERSION",
     "lib/subtrigger.rb",
     "lib/subtrigger/dsl.rb",
     "lib/subtrigger/path.rb",
     "lib/subtrigger/revision.rb",
     "lib/subtrigger/rule.rb",
     "lib/subtrigger/template.rb",
     "subtrigger.gemspec",
     "test/test_helper.rb",
     "test/test_path.rb",
     "test/test_revision.rb",
     "test/test_rule.rb",
     "test/test_template.rb"
  ]
  s.homepage = %q{http://github.com/avdgaag/subtrigger}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Create post-commit triggers for Subversion commit messages}
  s.test_files = [
    "test/test_helper.rb",
     "test/test_path.rb",
     "test/test_revision.rb",
     "test/test_rule.rb",
     "test/test_template.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_runtime_dependency(%q<pony>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<pony>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<pony>, [">= 0"])
  end
end

