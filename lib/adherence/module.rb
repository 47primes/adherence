module Adherence
  class ModuleTerminatedError < StandardError; end
  module Module

    def adheres_to(*args)
      args.each { |mod| adheres_to_module(mod) }
    end

    private

    def adheres_to_module(mod)
      raise ArgumentError, "Module expected" unless mod.class.to_s == "Module"

      mod.public_instance_methods(false).each do |method|
        add_method mod.instance_method(method)
      end

      mod.protected_instance_methods(false).each do |method|
        add_method mod.instance_method(method)
      end
      protected *mod.protected_instance_methods(false)

      mod.private_instance_methods(false).each do |method|
        add_method mod.instance_method(method)
      end
      private *mod.private_instance_methods(false)

      mod.singleton_class.public_instance_methods(false).each do |method|
        add_method mod.singleton_class.instance_method(method), true
      end

      mod.singleton_class.protected_instance_methods(false).each do |method|
        add_method mod.singleton_class.instance_method(method), true
      end
      singleton_class.send :protected, *mod.singleton_class.protected_instance_methods(false)

      mod.singleton_class.private_instance_methods(false).each do |method|
        add_method mod.singleton_class.instance_method(method), true
      end
      private_class_method *mod.singleton_class.private_instance_methods(false)
    end

  end
end
