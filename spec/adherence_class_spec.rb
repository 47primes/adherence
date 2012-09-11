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

  it "should succeed if the object has defined all behavior from the module" do
    expect do 
      class Duck
        adheres_to Animal

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
          new
        end
      end
    end.to_not raise_error
  end

  it "should raise an error if argument is not a module" do
    expect do 
      class Otter 
        adheres_to Class.new
      end
    end.to raise_error(ArgumentError)
  end

  it "should raise an error if a non-implemented class method is called" do
    class Dog
      adheres_to Animal

      def speak
        "woof"
      end

      def move(feet)
        "trots #{feet} feet"
      end

      private

      def life_expectancy
        13
      end
    end

    expect { Dog.build("fido") }.to raise_error(NotImplementedError)
  end

  it "should raise an error if a non-implemented instance method is called" do
    class Shark
      adheres_to Animal

      def move(feet)
        "swim #{feet} feet"
      end

      private

      def life_expectancy
        32
      end

      def self.build(name, &block)
        new
      end
    end

    expect { Shark.new.speak }.to raise_error(NotImplementedError)
  end

  it "should raise an error if a non-implemented private instance method is called" do
    class Horse
      adheres_to Animal

      def speak
        "neigh"
      end

      def move(feet)
        "gallop #{feet} feet"
      end

      private

      def self.build(name, &block)
        new
      end
    end

    expect { Horse.new.send(:life_expectancy) }.to raise_error(NotImplementedError)
  end

  it "should raise an error if instance method is implemented with an invalid signature" do
    expect do 
      class Bear
        adheres_to Animal

        def speak
          "grrrr"
        end

        def move(distance)
          "run #{distance} feet"
        end

        private

        def life_expectancy
          30
        end

        def self.build(name, &block)
          new
        end
      end
    end.to raise_error(Adherence::NotAdheredError, "Signature does not match Animal#move")
  end

  it "should raise an error if class method is implemented with an invalid signature", class_method: true do
    expect do 
      class Person
        adheres_to Animal

        def speak
          "hello"
        end

        def move(feet)
          "walk #{distance} feet"
        end

        private

        def life_expectancy
          80
        end

        def self.build(name)
          new
        end
      end
    end.to raise_error(Adherence::NotAdheredError, "Signature does not match Animal.build")
  end

end
