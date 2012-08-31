module Adherence
  class NotAdheredError < NotImplementedError; end
  module Class

    def adheres_to(*args)
      args.each {|mod| adheres_to_module mod}
    end

    private

    def adheres_to_module(mod)
      raise ArgumentError, "Module expected" unless mod.class.to_s == "Module"

      (mod.instance_methods(false) + mod.private_instance_methods(false)).each do |method|
        if !(instance_methods + private_instance_methods).include?(method)
          raise NotImplementedError, "#{self.class} must define #{method}"
        end
        if !equal? instance_method(method), mod.instance_method(method)
          raise NotAdheredError, "Signature does not match #{mod}##{method}"
        end
      end

      module_class_methods = mod.singleton_class.instance_methods(false) + mod.singleton_class.private_instance_methods(false)
      module_class_methods.each do |method|
        if !(singleton_class.instance_methods + singleton_class.private_instance_methods).include?(method)
          raise NotImplementedError, "#{self.class} must define self.#{method}"
        end
        if !equal? singleton_class.instance_method(method), mod.singleton_class.instance_method(method)
          raise NotAdheredError, "Signature does not match #{mod}.#{method}"
        end
      end
    end

    def equal?(method1, method2)
      method1.name == method2.name && method1.parameters == method2.parameters ? true : false
    end
  end
end
