require 'bundler/setup'
require 'dotenv/load'
require 'optparse'
require_relative 'backend/controller/app'

options = { port: 4567 }
OptionParser.new do |opts|
  opts.on('-p PORT', Integer, 'Port to run on') { |port| options[:port] = port }
end.parse!(ARGV)

App.run!(port: options[:port]) if __FILE__ == $PROGRAM_NAME