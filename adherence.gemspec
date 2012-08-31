Gem::Specification.new do |spec|
  spec.name         = "adherence"
  spec.version      = "0.1.0"
  spec.date         = "2012-08-30"
  spec.summary      = "Adds simple interface-like behavior to Ruby"
  spec.authors      = ["Mike Bradford"]
  spec.email        = "mbradford@47primes.com"
  spec.files        = Dir["#{File.dirname(__FILE__)}/**/*"]
  spec.test_files   = Dir.glob("spec/*_spec.rb")
  spec.homepage     = "http://github.com/47primes/adherence"

  spec.add_development_dependency "rspec", "~> 2.11.0"
end