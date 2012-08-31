require "adherence"

module Vehicle
  def initialize(make, model) end

  def start() end

  def stop() end

  def accellerate(speed) end

  def turn(orientation, speed=5, *args) end

  protected

  def repair(area, &block) end

  module ClassMethods
    class <<self
      def build(*args, &block) end

      protected

      def run() end

      private

      def helper(object) end
    end
  end
end

module Watercraft
  adheres_to Vehicle, Vehicle::ClassMethods

  def dock() end
end

describe Module, "adheres_to" do
  it "should raise an error if argument is not a module" do
    expect { Module.new { adheres_to(Class.new())} }.to raise_error(ArgumentError)
  end

  it "should define public instance methods based on module" do
    Watercraft.instance_method(:start).parameters.should == []
    Watercraft.instance_method(:stop).parameters.should == []
    Watercraft.instance_method(:accellerate).parameters.should == [[:req, :speed]]
    Watercraft.instance_method(:turn).parameters.should == [[:req, :orientation], [:opt, :speed], [:rest, :args]]
  end

  it "should define protected instance methods based on module" do
    Watercraft.protected_method_defined?(:repair).should be_true
    Watercraft.instance_method(:repair).parameters.should == [[:req, :area], [:block, :block]]
  end

  it "should define private instance methods based on module" do
    Watercraft.private_method_defined?(:initialize).should be_true
    Watercraft.instance_method(:initialize).parameters.should == [[:req, :make], [:req, :model]]
  end

  it "should define public class methods based on module" do
    Watercraft.singleton_class.public_instance_method(:build).parameters.should == [[:rest, :args], [:block, :block]]
  end

  it "should define protected class methods based on module" do
    Watercraft.singleton_class.protected_instance_methods.include?(:run).should be_true
    Watercraft.singleton_class.instance_method(:run).parameters.should == []
  end

  it "should define private class methods based on module" do
    Watercraft.singleton_class.private_instance_methods.include?(:helper).should be_true
    Watercraft.singleton_class.instance_method(:helper).parameters.should == [[:req, :object]]
  end

  it "should define all public instance methods to raise an error when called directly" do
    JetSki = Class.new do
      include Watercraft

      def initialize(make, model)
      end
    end

    jet_ski = JetSki.new("Kawasaki","Ultra 300LX")

    expect { jet_ski.start }.to raise_error(NotImplementedError)
    expect { jet_ski.stop }.to raise_error(NotImplementedError)
    expect { jet_ski.accellerate(10) }.to raise_error(NotImplementedError)
    expect { jet_ski.turn(90, -5) }.to raise_error(NotImplementedError)
  end

  it "should define all protected instance methods to raise an error when called directly" do
    OceanLiner = Class.new do
      include Watercraft

      def initialize(make, model)
      end
    end

    expect { OceanLiner.new("RMS","Titanic").send(:repair, "stern") }.to raise_error(NotImplementedError)
  end

  it "should define all private instance methods to raise an error when called directly" do
    RowBoat = Class.new do
      include Watercraft
    end

    expect { RowBoat.new("Freebooter","Row Boat") }.to raise_error(NotImplementedError)
  end

  it "should define all public class methods to raise an error when called directly" do
    Automobile = Module.new do
      adheres_to Vehicle::ClassMethods
    end

    expect { Automobile.build("Cadillac") {|c| c.year = 2012} }.to raise_error(NotImplementedError)
  end

  it "should define all protected class methods to raise an error when called directly" do
    Locomotive = Module.new do
      adheres_to Vehicle::ClassMethods
    end

    expect { Locomotive.send(:run) }.to raise_error(NotImplementedError)
  end

  it "should define all private class methods to raise an error when called directly" do
    Bicycle = Module.new do
      adheres_to Vehicle::ClassMethods
    end

    expect { Bicycle.send(:helper, "object") }.to raise_error(NotImplementedError)
  end
end
