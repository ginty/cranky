require "spec_helper"

describe Cranky do

  before(:each) do
  end

  it "should be alive" do
    Factory.build(:user).class.should == User
  end

  it "should not save the item when generated via build" do 
    Factory.build(:user).saved?.should == false
  end

  it "should save the item when generated via create" do 
    Factory.create(:user).saved?.should == true
  end

  it "should allow all attributes to be overriden in the call" do
    u = Factory.build(:user, :name => "Indy", :email => "indy@home.com", :role => :dog, :unique => :yep)
    u.name.should == "Indy"
    u.email.should == "indy@home.com"
    u.role.should == :dog
    u.unique.should == :yep
  end

  it "should return valid attributes rather than the model (rails only)" do
    attrs = Factory.attributes_for(:user)
    attrs.class.should == Array
  end

  it "should clear all instance variables when reset" do
    Factory.some_instance_variable = true
    Factory.some_instance_variable.should == true
    Factory.reset
    Factory.some_instance_variable.should == nil
  end

  it "should be able to create items using the define helper or manually" do
    m = Factory.build(:user_manually)
    d = Factory.build(:user_by_define)
    m.name.should ==  d.name
    m.email.should ==  d.email
    m.role.should ==  d.role
  end

  it "should be able to build by inheriting and overriding from other methods" do
    a = Factory.build(:admin_manually)
    a.name.should == "Fred"
    a.role.should == :admin
    b = Factory.build(:admin_by_define)
    b.name.should == "Fred"
    b.role.should == :admin
  end

  it "should create unique values using the n method" do
    a = Factory.build(:user)  
    b = Factory.build(:user)  
    c = Factory.build(:user)  
    a.unique.should_not == b.unique
    a.unique.should_not == c.unique
    b.unique.should_not == c.unique
  end
  
  it "should raise an error if the factory produces an invalid object when debug is enabled (rails only)" do
    Factory.debug = true
    error = false
    begin
      Factory.build(:user)
    rescue
      error = true 
    end
    error.should == true
    Factory.debug = false
  end

  it "should allow arguments to be passed in the overrides hash" do
    Factory.build(:user).argument_received.should == nil
    Factory.build(:user, :argument_supplied => true).argument_received.should == true
  end
  
end

