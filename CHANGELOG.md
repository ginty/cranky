# Overview of Changes

## 0.3.0

* Factory.debug was broken on ActiveModel based classes, now works with them

* Attributes can be skipped by setting the value to :skip. e.g. crank(:user, :name => :skip) will
  generate a User instance without calling or assigning anything to the name attribute

* Updated dev environment for latest rspec compatibility (2.6.0)

## 0.2.0 

Changes between version prior to this were not tracked here
