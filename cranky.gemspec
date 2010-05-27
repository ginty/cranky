require "lib/cranky"

Gem::Specification.new do |gem|
  gem.name         = 'cranky'
  gem.version      = Cranky::VERSION
                   
  gem.summary      = "A very light yet powerful test factory framework."
  gem.description  = "A very light yet powerful test factory framework with an extremely clean syntax that makes it very easy to define your factories."
                   
  gem.author       = "Stephen McGinty"
  gem.email        = "ginty@hyperdecade.com"
  gem.homepage     = "http://github.com/ginty/cranky"
                   
  gem.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"]
  gem.require_path = "lib"

  gem.required_rubygems_version = ">= 1.3.4"
end
