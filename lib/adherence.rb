Dir.glob(File.dirname(__FILE__) + "/adherence/*.rb").each {|f| require f}

module Adherence
	module HelperMethods
		private

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

class Module
  include Adherence::HelperMethods
  include Adherence::Module
end

class Class
	include Adherence::HelperMethods
  include Adherence::Class
end
