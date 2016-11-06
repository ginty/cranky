require 'simplecov'
SimpleCov.start

require 'cranky'
require 'active_model'

RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = :should }
end

class TestClass
  include ActiveModel::Validations

  attr_accessor :required_attr

  validates_presence_of :required_attr

  def save
    @saved = true
  end

  def save!
    if invalid?
      raise "Validation failed: #{errors.messages}"
    end
    save
  end

  def saved?
    !!@saved
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

  def user_manually
    u = User.new
    u.name = "Fred"
    u.role = options[:role] || :user
    u.unique = "value#{n}"
    u.email = "fred@home.com"
    u.address = Factory.build(:address)
    u.required_attr = true
    u
  end

  def user_by_define
    u = define :class => :user,
               :name => "Fred",
               :role => :user,
               :unique => "value#{n}",
               :email => "fred@home.com",
               :address => Factory.create(:address),
               :required_attr => true
    u.argument_received = true if options[:argument_supplied]
    u
  end
  alias :user :user_by_define

  def admin_manually
    inherit(:user_manually, role: :admin, required_attr: true)
  end

  def admin_by_define
    inherit(:user_by_define, :role => :admin)
  end

  def address
    define :address => "25 Wisteria Lane",
           :city => "New York",
           :required_attr => true
  end

  def user_hash
    define :class => Hash,
           :name => "Fred",
           :role => :user
  end

  def users_collection
    3.times.map { build(:user) }
  end

  def apply_trait_manager_to_user_manually(user)
    user.role = :manager
  end

  def apply_trait_invalid_to_user(user)
    user.required_attr = nil
  end

  def invalid_user
    inherit(:user, required_attr: false)
  end
end
