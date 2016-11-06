# Cranky

Cranky is a fixtures replacement inspired by the excellent Factory Girl but with easier syntax and no external
dependencies, it will work straight out of the box with rails 10.

In short use this if you want to quickly and naturally create factory methods that you feel 100% in control of.

## Install

First install the gem...

~~~
gem install cranky
~~~

Or with bundler...

~~~ruby
# Gemfile
gem "cranky"
~~~

Then in your spec_helper.rb ...

~~~ruby
# spec_helper.rb
require "cranky"
require "factories/my_factories"
~~~

The above assumes that you have created your factory methods in a file called my_factories.rb in the spec/factories directory.
You can create as many different factory files as you want, just require them in the same way.

## In a Nutshell

The API to use in your tests is:

~~~ruby
crank(:user)                  # Build a user instance without saving
crank!(:user)                 # Build and save a user instance
crank(:user, :name => "Ian")  # Override a default attribute value
crank(:user_attrs)            # Return a set of valid attributes rather than the object
~~~

Alternatively the Factory Girl syntax also works and therefore Cranky can drop into tests already written for that framework...

~~~ruby
Factory.build(:user)                  # Build a user instance without saving
Factory.create(:user)                 # Build and save a user instance
Factory.build(:user, :name => "Ian")  # Override a default attribute value
Factory.attributes_for(:user)         # Return a set of valid attributes rather than the object
~~~

Or if you're coming from Machinist, you can make your Cranky factories drop into your existing tests by setting up make and make! methods as [shown here](http://gist.github.com/525653).

Cranky has a nice debug option (rails only) to warn you when your factory is broken, recommend you do this for your first spec...

~~~ruby
describe User do
  it "should have a working factory" do
    # This will raise an error and report the validation errors should they occur
    Factory.debug(:user).should be_valid
  end
end
~~~

Cranky allows you to build factories via std Ruby methods, like this...

~~~ruby
# factories/my_factories.rb
class Cranky::Factory     # Your factory must reopen Cranky::Factory

  # Simple factory method to create a user instance, you would call this via crank(:user)
  def user
    # Define attributes via a hash, generate the values any way you want
    define :name    => "Jimmy",               
           :email   => "jimmy#{n}@home.com",   # An 'n' counter method is available to help make things unique
           :role    => "pleb",
           :address => default_address         # Call your own helper methods to wire up your associations
  end

  # Easily create variations via the inherit helper, callable via crank(:admin)
  def admin
    inherit(:user, :role => "admin")
  end

  # Return a default address if it already exists, or call the address factory to make one
  def default_address
    @default_address ||= create(:address) 
  end
  
  # Alternatively loose the DSL altogether and define the factory yourself, still callable via crank(:address)
  def address
    a = Address.new
    a.street = "192 Broadway"
    a.city = options[:city] || "New York"   # You can get any caller overrides via the options hash
    a                                       # Only rule is that the method must return the generated object 
  end

end
~~~

# Details

## Define Your Factories

This is where Cranky really shines, if you can create Ruby methods you can pretty much create your factories without having to refer to the syntax documentation ever again.

The only rules are:

1. Your factory must reopen the Cranky::Factory class
2. Your factory method must return the object you wanted to create (or an array containing a collection of them)
3. You can access the overrides passed in via `options[:key]` or `fetch(:key)`. (not really a rule!)

So for example to create a simple user factory...

~~~ruby
# factories/my_factories.rb
class Cranky::Factory

  # Simple factory method to create a user instance, you would call this via crank(:user)
  def user
    User.new do |u|
      u.name  = options[:name] || "Jimmy"                 # Use the passed in name if present, or the default
      u.nickname  = fetch(:nickname, 'Silencer')          # Use the passed in nickname if present, or the default
      u.phone  = fetch(:phone, 'phoneless')               # Use the passed in phone if present, or the default

      u.email = fetch(:email) { "jimmy#{n}@home.com" }    # Give each user a unique email address
      u.role  = fetch(:role, 'pleb')
    end
  end

end
~~~

Now of course you are working in straight Ruby here, so you can extend this any way you want as long as you follow the above rules. 

For example here it is with the capability to automatically create a default address association...

~~~ruby
# factories/my_factories.rb
class Cranky::Factory

  # Return the default address if it already exists, or call the address factory to make one
  def default_address
    @default_address ||= create(:address) 
  end

  def user
    User.new do |u|
      u.name    = fetch(:name, "Jimmy")
      u.email   = fetch(:email) { "jimmy#{n}@home.com" }
      u.role    = fetch(:role, "pleb")
      u.address = fetch(:address) { default_address }
    end
  end

  # Create the address factory in the same way

end
~~~

Quite often the database will be cleared between tests but the instance variable in the factory will not necessarily be reset which could lead to problems if the tests check for the associated record in the database.
So a nice tip is to implement default associations like this (assuming you're using Rails)...

~~~ruby
# Return the default address if it already exists, or call the address factory to make one
def default_address
  # If the default address exists, but has been cleared from the database...
  @default_address = nil if @default_address && !Address.exists?(@default_address.id)
  @default_address ||= create(:address) 
end
~~~

You can pass additional arguments to your factories via the overrides hash...

~~~ruby
crank(:user, :new_address => true)

def user
  User.new do |u|
    u.name    = fetch(:name, "Jimmy")
    u.email   = fetch(:email) { "jimmy#{n}@home.com" }
    u.role    = fetch(:role, "pleb")
    u.address = options[:new_address] ? create(:address) : default_address
  end
end
~~~

You can use traits...

~~~ruby
crank(:user, traits: [:admin, :manager])

def user
  User.new do |u|
    u.name    = fetch(:name, "Jimmy")
    u.email   = fetch(:email) { "jimmy#{n}@home.com" }
    u.role    = fetch(:role, "pleb")
    u.address = options[:new_address] ? create(:address) : default_address
  end
end

def apply_trait_admin_to_user(user)
  user.roles << :admin
end

def apply_trait_manager_to_user(user)
  user.roles << :manager
end
~~~

You can create collections...

~~~ruby
crank(:users_collection)

def users_collection
  3.time.map { build(:user) }
end
~~~

## Linting Factories

Cranky allows for linting known factories:

~~~ruby
Factory.lint!
~~~

`Factory.lint!` creates each factory and catches any exceptions raised during the creation process. `Cranky::Linter::InvalidFactoryError` is raised with a list of factories (and corresponding exceptions) for factories which could not be created.

Recommended usage of `Factory.lint!` is to run this in a task before your test suite is executed. Running it in a `before(:suite)`, will negatively impact the performance of your tests when running single tests.

Example Rake task:

~~~ruby
# lib/tasks/factory_girl.rake
namespace :cranky do
  desc "Verify that all factories are valid"
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        Factory.lint!
      ensure
        DatabaseCleaner.clean
      end
    else
      system("bundle exec rake cranky:lint RAILS_ENV='test'")
    end
  end
end
~~~

After calling `Factory.lint!`, you'll likely want to clear out the database, as records will most likely be created. The provided example above uses the database_cleaner gem to clear out the database; be sure to add the gem to your Gemfile under the appropriate groups.

You can lint factories selectively by passing only factories you want linted:

~~~ruby
factories_to_lint = Factory.factory_names.reject do |name|
  name =~ /^old_/
end

Factory.lint! factories_to_lint
~~~

This would lint all factories that aren't prefixed with `old_`.

Traits can also be linted. This option verifies that each
and every trait of a factory generates a valid object on its own. This is turned on by passing traits: true to the lint method:

~~~ruby
Factory.lint! traits: true
~~~

This can also be combined with other arguments:

~~~ruby
Factory.lint! factories_to_lint, traits: true
~~~

## Helpers

Of course its nice to get some help...

### Define

Most of your factories are likely to simply define a list of mimimum attribute values, use the define helper for this. 

~~~ruby
# The user factory re-written using the define helper
def user
  define :name    => "Jimmy",
         :email   => "jimmy#{n}@home.com",
         :role    => "pleb",
         :address => default_address
end
~~~

Note that you don't have to worry about handling the overrides here, they will be applied automatically if present, just define the defaults.

The define argument is just a regular hash, you have complete freedom to choose how to generate the values to be passed into it.

If you like you can generate attributes with a block:

~~~ruby
def user
  define :name    => "Jimmy",
         :email   => -> { |u| "#{u.name.downcase}@home.com" },
         :role    => "pleb",
         :address => default_address
end
~~~

The define method will return the object, you can grab this for additional manipulation as you would expect...

~~~ruby
def user
  u = define :name    => "Jimmy",
             :email   => "jimmy#{n}@home.com",
             :role    => "pleb",
             :address => default_address
  u.do_something
  u               # Remember to return it at the end
end
~~~

If for any reason you want to have your factory method named differently from the model it instantiates you can pass in a :class attribute to the define method...

~~~ruby
# Called via crank(:jimmy)
def jimmy
  u = define :class   => :user, 
             :name    => "Jimmy",
             :email   => "jimmy#{n}@home.com",
             :role    => "pleb",
             :address => default_address
end
~~~

### Inherit

You can inherit from other factories via the inherit method. So for example to create an admin user you might do...

~~~ruby
# Called via crank(:admin)
def admin
  inherit(:user, :role => "admin")  # Pass in any attribute overrides you want
end
~~~

### Unique Attributes (n)

If you want to generate unique attributes you can call the n method which will automatically increment the next time it is called.

Note that every time n is called it will increment, it does not implement a unique counter per attribute.

### Reset

Clear all instance variables in the factory. This may be useful to run between tests depending on your factory logic...

~~~ruby
before(:each) do
  Factory.reset
end
~~~

### Debug

Sometimes it is useful to be warned that your factory is generating invalid instances (although quite often your tests may intentionally generate invalid instances, so use this with care). By turning on debug the Factory will raise an error if the generated instance is invalid...

~~~ruby
Factory.debug(:user)   # A replacement for Factory.build, with validation errors enabled
Factory.debug!(:user)  # Likewise for Factory.create
~~~

Note that this relies on the instance having a valid? method, so in practice this may only work with models that include ActiveModel::Validations.

### Attributes For

Returns the attributes that would be applied by a given factory method...

~~~ruby
valid_attributes = Factory.attributes_for(:user)
~~~

Requires that the instance has an attributes method, so again may only work under Rails.

## Additional Features

Want any? Feel free to let me know.

## Thanks

Cranky was inspired by [factory_girl](http://github.com/thoughtbot/factory_girl) and [miniskirt](http://gist.github.com/273579).

Thanks to both.

