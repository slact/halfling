require 'hobbit/response'

module Hobbit
  class Response
    def finish      
      if status == 204 || status == 205 || status == 304 || (100..199).include?(status)
        headers.delete 'Content-Type'
      else
        headers['Content-Length'] = @length.to_s
      end
      [status, headers, body]
    end
  end
end
