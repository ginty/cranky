require "lib/cranky"

Gem::Specification.new do |gem|
  gem.name         = 'cranky'
  gem.version      = Cranky::VERSION
                   
  gem.summary      = "A simple yet powerful test factory framework."
  gem.description  = "A simple yet powerful test factory framework that makes it very easy to define your own factories without a block in sight."
                   
  gem.author       = "Stephen McGinty"
  gem.email        = "ginty@hyperdecade.com"
  gem.homepage     = "http://github.com/ginty/cranky"
                   
  gem.files        = Dir["{lib,spec}/**/*", "[A-Z]*", "init.rb"]
  gem.require_path = "lib"

  gem.required_rubygems_version = ">= 1.3.4"
end
