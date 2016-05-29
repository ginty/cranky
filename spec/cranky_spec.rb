require "spec_helper"

describe "The Cranky factory" do

  before(:each) do
  end

  it "is alive" do
    Factory.build(:user).class.should == User
  end

  it "does not save the item when generated via build or crank" do 
    Factory.build(:user).saved?.should == false
    crank(:user).saved?.should == false
  end

  it "does save the item when generated via create or crank!" do 
    Factory.create(:user).saved?.should == true
    crank!(:user).saved?.should == true
  end

  it "allows all attributes to be overriden in the call" do
    u = Factory.build(:user, :name => "Indy", :email => "indy@home.com", :role => :dog, :unique => :yep)
    u.name.should == "Indy"
    u.email.should == "indy@home.com"
    u.role.should == :dog
    u.unique.should == :yep
  end

  it "returns valid attributes rather than the model" do
    Factory.attributes_for(:user).class.should == Hash
  end

  it "clears all instance variables when reset" do
    Factory.some_instance_variable = true
    Factory.some_instance_variable.should == true
    Factory.reset
    Factory.some_instance_variable.should == nil
  end

  it "can create items using the define helper or manually" do
    m = Factory.build(:user_manually)
    d = Factory.build(:user_by_define)
    m.name.should ==  d.name
    m.email.should ==  d.email
    m.role.should ==  d.role
  end

  it "can build by inheriting and overriding from other methods" do
    a = Factory.build(:admin_manually)
    a.name.should == "Fred"
    a.role.should == :admin
    b = Factory.build(:admin_by_define)
    b.name.should == "Fred"
    b.role.should == :admin
  end

  it "gives top priority to attributes defined at the top level, even when inheriting" do
    a = Factory.build(:admin_manually, :role => :something_else)
    a.role.should == :something_else
    b = Factory.build(:admin_by_define, :role => :something_else)
    b.role.should == :something_else
  end

  it "creates unique values using the n method" do
    a = Factory.build(:user)  
    b = Factory.build(:user)  
    c = Factory.build(:user)  
    a.unique.should_not == b.unique
    a.unique.should_not == c.unique
    b.unique.should_not == c.unique
  end
  
  describe "debugger" do 

    it "raises an error if the factory produces an invalid object when enabled (rails only)" do
      error = false
      begin
        Factory.debug(:user, :valid => false)
      rescue
        error = true 
      end
      error.should == true
    end

    it "debug works like build and create when there are no errors" do
      Factory.debug(:user).class.should == User
      Factory.debug(:user).saved?.should == false
      Factory.debug!(:user).saved?.should == true
    end

  end

  it "allows arguments to be passed in the overrides hash" do
    Factory.build(:user).argument_received.should == nil
    Factory.build(:user, :argument_supplied => true).argument_received.should == true
  end

  it "allows blocks to be passed into the define method" do
    Factory.build(:user, :name => "jenny", :email => lambda{ |u| "#{u.name}@home.com" }).email.should == "jenny@home.com"
    Factory.build(:user, :name => lambda { |u| "jimmy" + " cranky" }).name.should == "jimmy cranky"
    Factory.build(:user, :name => "jenny", :email => Proc.new{ |u| "#{u.name}@home.com" }).email.should == "jenny@home.com"
    Factory.build(:user, :name => Proc.new{ |u| "jimmy" + " cranky" }).name.should == "jimmy cranky"
  end

  it "allows factories to call other factories" do
    Factory.build(:user_manually).address.city.should == "New York"
    Factory.create(:user_manually).address.city.should == "New York"
    Factory.create(:user_manually).address.saved?.should == false
    Factory.build(:user_by_define).address.city.should == "New York"
    Factory.create(:user_by_define).address.city.should == "New York"
    Factory.create(:user_by_define).address.saved?.should == true
  end

  it "has its own syntax" do
    crank(:user).saved?.should == false
    crank!(:address).saved?.should == true
  end

  it "is capable of creating user hashes" do
    Factory.build(:user_hash)[:name].should == "Fred"
    Factory.build(:user_hash)[:role].should == :user
    Factory.build(:user_hash)[:class].should be_nil
  end

  it "is capable of overriding user hashes" do
    Factory.build(:user_hash, :role => :admin)[:role].should == :admin
  end

  it "is capable of using traits" do
    user = Factory.build(:user_manually, :traits => :manager)
    user.role.should == :manager
  end

  it "raises exception if trait method is undefined" do
    expect { Factory.build(:user_by_define, :traits => :manager) }.to raise_error("Invalid trait 'manager'! No method 'apply_trait_manager_to_user_by_define' is defined.")
  end

  specify "attributes are not assigned when they have the value :skip" do
    crank(:user, :name => :skip).name.should_not be
  end

  it "returns an hash of attributes when the 1st argument is appended with _attrs" do
    crank(:user_attrs).class.should == Hash
    crank(:user_attrs, :name => "Yo")[:name].should == "Yo"
  end

  it "returns nothing extra in the attributes" do
    crank(:user_attrs).size.should == 6
  end

  specify "attributes for works with factory methods using inherit" do
    crank(:admin_by_define_attrs).class.should == Hash
  end

end

