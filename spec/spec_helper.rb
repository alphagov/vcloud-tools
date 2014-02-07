require 'simplecov'

SimpleCov.profiles.define 'gem' do
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/vendor/'

  add_group 'Libraries', '/lib/'
end

SimpleCov.start 'gem'

require 'bundler/setup'
require 'vcloud'
require 'support/stub_fog_interface.rb'


SimpleCov.at_exit do
  SimpleCov.result.format!
  # do not change the coverage percentage, instead add more unit tests to fix coverage failures.
  if SimpleCov.result.covered_percent < 71
    print "ERROR::BAD_COVERAGE\n"
    print "Coverage is less than acceptable limit(71%). Please add more tests to improve the coverage"
    exit(1)
  end
end

class ErbHelper
  def self.generate_input_yaml_config test_namespace, input_erb_config
    input_erb_config = input_erb_config
    e = ERB.new(File.open(input_erb_config).read)
    output_yaml_config = File.join(File.dirname(input_erb_config), "output_#{Time.now.strftime('%s')}.yaml")
    File.open(output_yaml_config, 'w') { |f|
      f.write e.result(OpenStruct.new(test_namespace).instance_eval { binding })
    }
    output_yaml_config
  end
end
