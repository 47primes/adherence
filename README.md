# Adherence

Adherence adds simple interface-like behavior to Ruby.

## Description

A common practice in object oriented programming languages is to declare abstract behavior in a certain type whose actual behavior must be defined by types implementing the abstract type.

In Java, for example, this is abstract behavior may be defined in an abstract class or an interface. In many dynamically types languages, like Ruby, duck typing makes these abstract types unneccessary. However, it is common to see in Ruby programs the following abstract-like method pattern:

```ruby
class Validator
  def validate(record)
    raise NotImplementedError, "Subclasses must implement a validate(record) method."
  end
end
```

Adherence provides a simple means of declaring abstract behavior in Ruby modules and enforcing their complete implementation in any class adhereing to this module.

## Usage

### Classes

A class may adhere to any number of modules by use of the adheres_to method.

```ruby
module ElectronicDevice
  def on() end

  def off() end

  def self.compatible?(device1, device2) end
end

module Calculator
  def add(x1, x2) end

  def subtract(x1, x2) end

  def multiply(x1, x2) end

  def divide(x1, x2) end
end

class TexasInstruments
  adheres_to ElectronicDevice, Calculator

  def on
    @power = true
  end

  def off
    @power = false
  end

  def add(x1, x2)
    x1 + x2
  end

  def subtract(x1, x2)
    x1 - x2
  end

  def multiply(x1, x2)
    x1 * x2
  end

  def divide(x1, x2)
    x1 / x2
  end

  def self.compatible?(device1, device2)
    device1.respond_to?(:add) && device2.respond_to?(:add)
  end
end
```

When adheres_to is called, the existing class and instance methods defined in the class are inspected. A check is made on any method whose name and visibility matches that of a method defined in one of the specified modules. If the signature of the method defined in the class does not match that of the method defined in the module, an Adherence::NotAdheredError will be raised. Similarly, any methods defined after adheres_to is called will be inspected when added to the class. Any method not defined in the class will raise a NotImplementedError when invoked:

```ruby
class HewlettPackard
adheres_to ElectronicDevice, Calculator

  def on
    @power = true
  end

  def off
    @power = false
  end

  def add(x1, x2)
    x1 + x2
  end

  def subtract(x1, x2)
    x1 - x2
  end

  def multiply(x1, x2)
    x1 * x2
  end
end

> device1 = HewlettPackard.new
> device2 = HewlettPackard.new

> device1.divide(12, 4)
Adherence::NotImplementedError: "HewlettPackard must define divide"

> HewlettPackard.compatible?(device1, device2)
Adherence::NotImplementedError: "HewlettPackard must define compatible?"
```

### Modules

A module may adhere to other modules:

```ruby
module ScientificCalculator
  adhere_to Calculator

  def factorial(n) end

  def power(base, exponent) end
end
```

In this case, the module is not expected to redefine the methods defined in the modules passed to adheres_to, rather these methods will be redefined within the calling module to raise an error when invoked directly. Thus the module ScientificCalculator in the example above will be redefined to look like this:

```ruby
module ScientificCalculator
  def on
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def off
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def add(x1, x2)
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def subtract(x1, x2)
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def multiply(x1, x2)
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def divide(x1, x2)
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def self.compatible?(device1, device2)
    raise NotImplementedError, "This method must be defined in the calling class."
  end

  def factorial(n) end

  def power(base, exponent) end
end
```

So if any class that includes or extends ScientificCalculator and does not override these methods, a NotImplementedError would be raised if any of them were called.

## Requirements

Due to some of the methods used to inspect method signatures, Adherence is only compatible with Ruby version >= 1.9.2-p180.

## Installation

    gem install adherence

## License

Adherence is released under the [MIT license](http://www.opensource.org/licenses/MIT). Copyright (c) 2012 Mike Bradford.