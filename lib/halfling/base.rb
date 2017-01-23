require "hobbit"
require "hobbit/base"
require "yaml"
require "pry"

module Hobbit
  class Base
    include Hobbit::Render
    include Hobbit::Environment
    
    class << self
      INITIALIZERS_PATH='config/initializers/**/*.rb'
      MODELS_PATH='app/models/**/*.rb'
      VIEWS_PATH='app/views'
      CONTROLLERS_PATH='app/controllers/**/*.rb'
      
      def inherited(sub)
        puts "inherited #{sub}, #{sub.superclass}, #{Base}"
        
        if sub.superclass == Base
          #config stuff
          if File.exists?('config/env.yml')
            all_conf=YAML.load_file 'config/env.yml'
            conf=all_conf[ENV['RACK_ENV']]
            @@config=conf
            @@application=sub
            use Rack::Config do |env|
              conf.each do |cf, val|
                env[cf.to_sym]=val
              end
            end
          end
         
          class << sub
            def inherited(sub)
              puts "#{self} REALLY inherited from #{sub}"
              
              name=sub.name.match(".*?::(.*)Controller")[1].downcase!
              if name == "root"
                @@root_controller = sub
              else
                @@controller_routes ||= {}
                @@controller_routes["/#{name}"]=sub
              end
            end

            #standard paths and stuff
            paths = [INITIALIZERS_PATH, MODELS_PATH, CONTROLLERS_PATH]
            paths.each do |path|
              Dir[path].sort!.each {|f| require File.expand_path(f) }
            end
          end
          
          #templates
          reload_templates
        end
      end
      
      def config
        @@config
      end
      
      def any(path, verbs, &block)
        verbs.each do |verb|
          routes[verb.to_s.upcase] << compile_route(path, &block)
        end
      end
      
      def reload_templates
        #find and remember all known templates
        @@templates={}
        Dir["#{VIEWS_PATH}/**/*.*"].each do |f|
          m=f.match(/^#{VIEWS_PATH}\/(?<tmpl>.*)\.\w+/)
          k=m[:tmpl].to_sym
          if @@templates[k]
            raise "Template for #{k} already present, should not overwrite. (wanted to replace #{@@templates[k]} with #{f})"
          end
          @@templates[k]=f
        end
      end
      
      private
      old_compile_route = instance_method(:compile_route)
      define_method :compile_route do |path, &block|
        route = { block: block, compiled_path: nil, extra_params: [], path: path }
        
        if Regexp === path
          compiled_path = path
          path.named_captures.each do |k, v|
            route[:extra_params] << k
          end
          route[:compiled_path] = compiled_path
        else
          route = old_compile_route.bind(self).(path, &block)
        end
        route
      end
    end
  
    def initialize
      if @@controller_routes
        @@controller_routes.each do |route, controller|
          puts "map #{route} to #{controller.name}"
          @@application.map(route) do
            run controller.new
          end
        end
        @@controller_routes = nil
      end
      if @@root_controller
        puts "map root / to #{@@root_controller.name}"
        root_controller = @@root_controller
        @@application.map("/") do
          run root_controller.new
        end
        @@root_controller = nil
      end
      super
    end
    
    #template stuff
    def find_template(template)
      tmpl_path=@@templates[template.to_sym]
      raise "template #{template} not found" unless tmpl_path
      tmpl_path
    end
    def default_layout
      find_template :"layouts/application"
    end
    def template_engine
      raise "template_engine shouldn't be called"
    end

    
    #convenience stuff
    def set_content_type (val)
      response.headers["Content-Type"]=val
    end
    def json_response!
      set_content_type "application/json"
    end
    def js_response!
      set_content_type "application/javascript"
    end
    def params
      request.params
    end
    def param(name)
      params[name]
    end
  end
end
