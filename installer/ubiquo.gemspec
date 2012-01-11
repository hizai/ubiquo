# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ubiquo"
  s.version = "0.9.0.b4"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Albert Callarisa", "Jordi Beltran", "Bernat Foj", "Eric Garc\303\255a", "Felip Ladr\303\263n", "David Lozano", "Antoni Reina", "Ramon Salvad\303\263", "Arnau S\303\241nchez"]
  s.date = "2012-01-11"
  s.description = "This gem provides a command-line interface to speed up the creation of ubiquo based apps."
  s.email = "rsalvado@gnuine.com"
  s.executables = ["ubiquo"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/ubiquo",
    "lib/ubiquo.rb",
    "lib/ubiquo/generator.rb",
    "lib/ubiquo/options.rb",
    "lib/ubiquo/template.erb",
    "test/fixtures/template.erb",
    "test/helper.rb",
    "test/ubiquo/generator_test.rb",
    "test/ubiquo/options_test.rb",
    "ubiquo.gemspec"
  ]
  s.homepage = "http://www.ubiquo.me"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.12"
  s.summary = "command line application for building ubiquo based applications."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<journey>, ["= 1.0.0.rc1"])
      s.add_runtime_dependency(%q<rails>, ["~> 3.2.0.rc2"])
    else
      s.add_dependency(%q<journey>, ["= 1.0.0.rc1"])
      s.add_dependency(%q<rails>, ["~> 3.2.0.rc2"])
    end
  else
    s.add_dependency(%q<journey>, ["= 1.0.0.rc1"])
    s.add_dependency(%q<rails>, ["~> 3.2.0.rc2"])
  end
end

