require 'rubygems'
require 'spec'
require 'cranky'

# A basic model to crank out
class User
  attr_accessor :name
  attr_accessor :role
  attr_accessor :email
  attr_accessor :unique
  attr_accessor :argument_received

  def save
    @saved = true
  end

  def saved?
    !!@saved
  end

  def valid?
    false
  end

  def errors
    "some validation errors"
  end

  def attributes
    self.instance_variables
  end

end

# Some basic factory methods
class Cranky

  attr_accessor :some_instance_variable

  def user_manually
    u = User.new    
    u.name = "Fred"
    u.role = options[:role] || :user
    u.unique = "value#{n}"
    u.email = "fred@home.com"
    u
  end

  def user_by_define
    u = define :class => :user, 
               :name => "Fred",
               :role => :user,
               :unique => "value#{n}",
               :email => "fred@home.com"
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

end



