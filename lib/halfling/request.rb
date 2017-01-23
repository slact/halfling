require "hobbit/request"

module Hobbit
  class Request
    class RequestHeaders
      include Enumerable
      def initialize(env)
        @env=env
      end
      
      def each
        @env.each do |var_name, val|
          if String === var_name
            if (match=var_name.match(/^HTTP_(.*)$/))
              header_name=match[1]
              unless header_name == "VERSION"
                yield header_name.split('_').map(&:capitalize).join('-'), val if block_given?
              end
            end
          end
        end
      end
      
      def [](header_name)
        @env[self.class.header_name_to_env_var(header_name)]
      end
      def self.header_name_to_env_var(header_name)
        "HTTP_#{header_name.upcase.gsub("-", "_")}"
      end
    end
    
    def header(name)
      env[RequestHeaders.header_name_to_env_var(name)]
    end
    def headers
      @headers_enumerable||=RequestHeaders.new(env)
    end
  end
end
