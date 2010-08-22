require "spec_helper"

describe "The Cranky factory" do

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

  it "should give top priority to attributes defined at the top level, even when inheriting" do
    a = Factory.build(:admin_manually, :role => :something_else)
    a.role.should == :something_else
    b = Factory.build(:admin_by_define, :role => :something_else)
    b.role.should == :something_else
  end

  it "should create unique values using the n method" do
    a = Factory.build(:user)  
    b = Factory.build(:user)  
    c = Factory.build(:user)  
    a.unique.should_not == b.unique
    a.unique.should_not == c.unique
    b.unique.should_not == c.unique
  end
  
  describe "debugger" do 

    it "should raise an error if the factory produces an invalid object when enabled (rails only)" do
      error = false
      begin
        Factory.debug(:user)
      rescue
        error = true 
      end
      error.should == true
    end

  end

  it "should allow arguments to be passed in the overrides hash" do
    Factory.build(:user).argument_received.should == nil
    Factory.build(:user, :argument_supplied => true).argument_received.should == true
  end

  it "should allow blocks to be passed into the define method" do
    Factory.build(:user, :name => "jenny", :email => lambda{ |u| "#{u.name}@home.com" }).email.should == "jenny@home.com"
    Factory.build(:user, :name => lambda{"jimmy" + " cranky"}).name.should == "jimmy cranky"
    Factory.build(:user, :name => "jenny", :email => Proc.new{ |u| "#{u.name}@home.com" }).email.should == "jenny@home.com"
    Factory.build(:user, :name => Proc.new{"jimmy" + " cranky"}).name.should == "jimmy cranky"
  end

  it "allows factories to call other factories" do
    Factory.build(:user_manually).address.city.should == "New York"
    Factory.create(:user_manually).address.city.should == "New York"
    Factory.create(:user_manually).address.saved?.should == false
    Factory.build(:user_by_define).address.city.should == "New York"
    Factory.create(:user_by_define).address.city.should == "New York"
    Factory.create(:user_by_define).address.saved?.should == true
  end

  it "should also have its own syntax" do
    crank(:user).saved?.should == false
    crank!(:address).saved?.should == true
  end
  
end

