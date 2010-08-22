require 'rubygems'
require 'spec'
require 'cranky'


class TestClass
  attr_accessor :valid

  def save
    @saved = true
  end

  def saved?
    !!@saved
  end

  def valid?
    @valid
  end

  def errors
    "some validation errors"
  end

  def attributes
    self.instance_variables
  end
end

# A basic model to crank out
class User < TestClass
  attr_accessor :name
  attr_accessor :role
  attr_accessor :email
  attr_accessor :unique
  attr_accessor :argument_received
  attr_accessor :address
end


class Address < TestClass
  attr_accessor :address
  attr_accessor :city
end

# Some basic factory methods
class Cranky::Factory

  attr_accessor :some_instance_variable

  def user_manually
    u = User.new    
    u.name = "Fred"
    u.role = options[:role] || :user
    u.unique = "value#{n}"
    u.email = "fred@home.com"
    u.address = Factory.build(:address)
    u.valid = true
    u
  end

  def user_by_define
    u = define :class => :user, 
               :name => "Fred",
               :role => :user,
               :unique => "value#{n}",
               :email => "fred@home.com",
               :address => Factory.create(:address),
               :valid => true
    u.argument_received = true if options[:argument_supplied]
    u
  end
  alias :user :user_by_define

  def admin_manually
    inherit(:user_manually, :role => :admin)
  end

  def admin_by_define
    inherit(:user_by_define, :role => :admin)
  end

  def address
    define :address => "25 Wisteria Lane",
           :city => "New York",
           :valid => true
  end

end



