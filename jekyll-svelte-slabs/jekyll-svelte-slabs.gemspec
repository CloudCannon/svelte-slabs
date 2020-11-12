# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "jekyll-svelte-slabs/version"

Gem::Specification.new do |s|
  s.name          = "jekyll-svelte-slabs"
  s.version       = JekyllSvelteSlabs::VERSION
  s.authors       = ["Liam Bigelow"]
  s.email         = ["liam@cloudcannon.com"]
  s.homepage      = "https://github.com/cloudcannon/svelte-slabs"
  s.summary       = "A Jekyll plugin to help render svelte components on Jekyll websites"

  s.files         = `git ls-files app lib`.split("\n")
  s.platform      = Gem::Platform::RUBY
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.add_dependency "jekyll", ">= 3.7", "< 5.0"
end