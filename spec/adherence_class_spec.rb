require "adherence"

module Animal
  def speak() end

  def move(feet) end

  private

  def life_expectancy() end

  class <<self
    def build(name, &block) end
  end
end

describe Object, "adheres_to" do

  before do
    class Duck
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def speak
        "quack"
      end

      def move(feet)
        "waddle #{feet} feet"
      end

      private

      def life_expectancy
        10
      end

      def self.build(name, &block)
        Duck.new(name)
      end
    end
  end

  it "should succeed if the object has defined all behavior from the module" do
    expect do 
      class Duck
        adheres_to Animal
      end
    end.to_not raise_error
  end

  it "should raise an error if argument is not a module" do
    expect do 
      class Duck 
        adheres_to Class.new
      end
    end.to raise_error(ArgumentError)
  end

  it "should raise an error if all methods are not implemented" do
    Duck.send(:remove_method, :speak)

    expect do 
      class Duck
        adheres_to Animal
      end
    end.to raise_error(NotImplementedError)
  end

  it "should raise an error if all private methods are not implemented" do
    Duck.send(:remove_method, :life_expectancy)

    expect do 
      class Duck
        adheres_to Animal
      end
    end.to raise_error(NotImplementedError)
  end

  it "should raise an error if all class methods are not implemented" do
    Duck.singleton_class.send(:remove_method, :build)

    expect { Duck.adheres_to(Animal) }.to raise_error(NotImplementedError)
  end

  it "should raise an error if methods are implemented with an invalid signature" do
    Duck.send(:remove_method, :move)
    Duck.class_eval do
      def move(distance)
        "waddle #{distance} feet"
      end
    end

    expect do 
      class Duck
        adheres_to Animal
      end
    end.to raise_error(Adherence::NotAdheredError)
  end

end
