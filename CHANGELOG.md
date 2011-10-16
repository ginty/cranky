# Overview of Changes

## 0.3.0

* Updated README to present the crank syntax as the default

* Appending the first argument with _attrs will return a hash of attributes rather than
  the object, i.e. crank(:user) returns a User instance, and crank(:user_attrs) returns
  a hash of valid attributes

* Factory.attributes_for now returns a hash of attributes rather than an array, this
  method is no longer dependent on rails

* \#3 Factory methods can generate attribute hashes by default by setting :class => Hash in 
  the define declaration (leemhenson)

* Factory.debug was broken on ActiveModel based classes, now works with them

* Attributes can be skipped by setting the value to :skip. e.g. crank(:user, :name => :skip) will
  generate a User instance without calling or assigning anything to the name attribute

* Updated dev environment for latest rspec compatibility (2.6.0)

## 0.2.0 

Changes between version prior to this were not tracked here
