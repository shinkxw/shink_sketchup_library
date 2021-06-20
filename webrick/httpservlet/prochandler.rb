module Shink::WEBrick
  module HTTPServlet

    ##
    # Mounts a proc at a path that accepts a request and response.
    #
    # Instead of mounting this servlet with WEBrick::HTTPServer#mount use
    # WEBrick::HTTPServer#mount_proc:
    #
    #   server.mount_proc '/' do |req, res|
    #     res.body = 'it worked!'
    #     res.status = 200
    #   end

    class ProcHandler < AbstractServlet
      # :stopdoc:
      def get_instance(server, *options)
        self
      end

      def initialize(proc)
        @proc = proc
      end

      def do_GET(request, response)
        @proc.call(request, response)
      end

      alias do_POST do_GET
      # :startdoc:
    end

  end
end
