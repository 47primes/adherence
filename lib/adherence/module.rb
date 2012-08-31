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

    def add_method(method, singleton_method=false)
        name   = method.name
        params = method.parameters.reduce([]) do |memo, word|
                    arity, param = word
                    case arity
                    when :req then memo << "#{param}"
                    when :opt then memo << "#{param}=nil"
                    when :block then memo << "&#{param}"
                    when :rest then memo << "*#{param}"
                    end
                  end.join(", ")
        
        module_eval <<-DEF
          def #{"self." if singleton_method}#{name}(#{params})
            raise NotImplementedError, "This method must be defined in the calling class."
          end
        DEF
    end

  end
end
