require 'cranky/version'
require 'cranky/job'
require 'cranky/linter'
require 'cranky/factory'

# Instantiate a factory, this enables an easy drop in for tests written for Factory Girl  
Factory = Cranky::Factory.new unless defined?(Factory)

# Alternative Cranky specific syntax:
#   crank(:user)   # equivalent to Factory.build(:user)
#   crank!(:user)  # equivalent to Factory.create(:user)
def crank(*args)
  Factory.build(*args)
end

def crank!(*args)
  Factory.create(*args)
end

