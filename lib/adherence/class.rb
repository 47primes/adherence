module Adherence
  class NotAdheredError < NotImplementedError; end
  module Class

    private

    def adheres_to(*mods)
      @adhered_modules = []

      mods.each {|mod| adheres_to_module mod}

      class_eval do
        def self.method_added(method)
          @adhered_modules.each do |mod|
            if mod.instance_methods(false).include?(method) && !equal?(instance_method(method), mod.instance_method(method))
              raise NotAdheredError, "Signature does not match #{mod}##{method}"
            end
          end
        end

        def self.singleton_method_added(method)
          @adhered_modules.each do |mod|
            if mod.singleton_class.instance_methods(false).include?(method) && !equal?(singleton_class.instance_method(method), mod.singleton_class.instance_method(method))
              raise NotAdheredError, "Signature does not match #{mod}.#{method}"
            end
          end
        end
      end
    end

    def adheres_to_module(mod)
      raise ArgumentError, "Module expected" unless mod.class.to_s == "Module"
      @adhered_modules << mod

      # Add all instance methods from mod not already defined in class

      public_instance_methods_to_add = mod.public_instance_methods(false).reject {|m| public_method_defined?(m)}
      protected_instance_methods_to_add = mod.protected_instance_methods(false).reject {|m| protected_method_defined?(m)}
      private_instance_methods_to_add = mod.private_instance_methods(false).reject {|m| private_method_defined?(m)}

      (public_instance_methods_to_add + protected_instance_methods_to_add + private_instance_methods_to_add).each do |method|
        add_method mod.instance_method(method)
      end
      public *public_instance_methods_to_add
      protected *protected_instance_methods_to_add
      private *private_instance_methods_to_add

      # Add all class methods from mod not already defined in class

      public_class_methods_to_add = mod.singleton_class.public_instance_methods(false).reject {|m| singleton_class.public_method_defined?(m)}
      protected_class_methods_to_add = mod.singleton_class.protected_instance_methods(false).reject {|m| singleton_class.protected_method_defined?(m)}
      private_class_methods_to_add = mod.singleton_class.private_instance_methods(false).reject {|m| singleton_class.private_method_defined?(m)}

      (public_class_methods_to_add + protected_class_methods_to_add + private_class_methods_to_add).each do |method|
        add_method mod.singleton_class.instance_method(method), true
      end
      singleton_class.send :public, *public_class_methods_to_add
      singleton_class.send :protected, *protected_class_methods_to_add
      singleton_class.send :private, *private_class_methods_to_add

      # Ensure all instance methods have the same signature of those defined in mod

      %w(public protected private).each do |visibility|
        send("#{visibility}_instance_methods", false).each do |method|
          if mod.send("#{visibility}_method_defined?", method) && !equal?(instance_method(method), mod.instance_method(method))
            raise NotAdheredError, "Signature does not match #{mod}##{method}"
          end
        end
      end

      # Ensure all class methods have the same signature of those defined in mod

      %w(public protected private).each do |visibility|
        singleton_class.send("#{visibility}_instance_methods", false).each do |method|
          if mod.singleton_class.send("#{visibility}_method_defined?", method) && !equal?(singleton_class.instance_method(method), mod.singleton_class.instance_method(method))
            raise NotAdheredError, "Signature does not match #{mod}.#{method}"
          end
        end
      end
    end

    class <<self
      attr_reader :adhered_modules
    end

    def equal?(method1, method2)
      method1.name == method2.name && method1.parameters == method2.parameters ? true : false
    end

  end
end
