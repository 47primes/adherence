Dir.glob(File.dirname(__FILE__) + "/adherence/*.rb").each {|f| require f}

module Adherence
end

class Module
  include Adherence::Module
end

class Class
  include Adherence::Class
end
