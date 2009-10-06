module Datamapper4Rails
  class IntegrationTest
    
    attr_accessor :generator_args

    attr_accessor :rails_template

    attr_accessor :directory
    
    def initialize
      @ruby = RUBY_PLATFORM =~ /java/ ? 'jruby' : 'ruby'
      @directory = 'tmp'
      @generator_args = []
      @rails_template = 'datamapper_rails_templates.rb'
      yield self if block_given?
      execute
    end

    def generate(*args)
      @generator_args << args.map(&:to_s).join(" ")
    end

    def execute
      FileUtils.rm_rf(@directory)
      run("-S rails -fm #{rails_template} #{directory}")  
      FileUtils.cd(@directory) do
        @generator_args.each do |arg|
          run("script/generate #{arg}")  
        end
        run("-S rake spec")
        #run("-S rake test:units")
      end

    end

    def run(command) 
      unless system("#{@ruby} #{command}")
        puts
        puts "error in: #{@ruby} #{command}"
        exit 1
      end
    end
    
  end
end
