require 'thread'
require 'socket'

module Shink::WEBrick

  ##
  # Server error exception

  class ServerError < StandardError; end

  ##
  # Base server class

  class SimpleServer

    ##
    # A SimpleServer only yields when you start it

    def SimpleServer.start
      yield
    end
  end

  ##
  # Base TCP server class.  You must subclass GenericServer and provide a #run
  # method.

  class GenericServer

    ##
    # The server status.  One of :Stop, :Running or :Shutdown

    attr_reader :status

    ##
    # The server configuration

    attr_reader :config

    ##
    # The server logger.  This is independent from the HTTP access log.

    attr_reader :logger

    ##
    # Tokens control the number of outstanding clients.  The
    # <code>:MaxClients</code> configuration sets this.

    attr_reader :tokens

    ##
    # Sockets listening for connections.

    attr_reader :listeners

    ##
    # Creates a new generic server from +config+.  The default configuration
    # comes from +default+.

    def initialize(config={}, default=Config::General)
      @config = default.dup.update(config)
      @status = :Stop
      @config[:Logger] ||= Log::new
      @logger = @config[:Logger]

      @tokens = SizedQueue.new(@config[:MaxClients])
      @config[:MaxClients].times{ @tokens.push(nil) }

      rubyv = "#{RUBY_VERSION} (#{RUBY_RELEASE_DATE}) [#{RUBY_PLATFORM}]"
      @logger.info("WEBrick #{VERSION}")
      @logger.info("ruby #{rubyv}")

      @listeners = []
      @shutdown_pipe = nil
      unless @config[:DoNotListen]
        if @config[:Listen]
          warn(":Listen option is deprecated; use GenericServer#listen")
        end
        listen(@config[:BindAddress], @config[:Port])
        if @config[:Port] == 0
          @config[:Port] = @listeners[0].addr[1]
        end
      end
    end

    ##
    # Retrieves +key+ from the configuration

    def [](key)
      @config[key]
    end

    def listen(address, port)
      @listeners += Utils::create_listeners(address, port, @logger)
      setup_shutdown_pipe
    end

    def start(&block)
      raise ServerError, "already started." if @status != :Stop
      server_type = @config[:ServerType] || SimpleServer

      server_type.start{
        @logger.info \
          "#{self.class}#start: pid=#{$$} port=#{@config[:Port]}"
        call_callback(:StartCallback)

        shutdown_pipe = @shutdown_pipe

        thgroup = ThreadGroup.new
        @status = :Running
        begin
          while @status == :Running
            begin
              if svrs = IO.select([shutdown_pipe[0], *@listeners], nil, nil, 2.0)
                if svrs[0].include? shutdown_pipe[0]
                  break
                end
                svrs[0].each{|svr|
                  @tokens.pop          # blocks while no token is there.
                  if sock = accept_client(svr)
                    sock.do_not_reverse_lookup = config[:DoNotReverseLookup]
                    th = start_thread(sock, &block)
                    th[:WEBrickThread] = true
                    thgroup.add(th)
                  else
                    @tokens.push(nil)
                  end
                }
              end
            rescue Errno::EBADF, Errno::ENOTSOCK, IOError => ex
              # if the listening socket was closed in GenericServer#shutdown,
              # IO::select raise it.
            rescue StandardError => ex
              msg = "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
              @logger.error msg
            rescue Exception => ex
              @logger.fatal ex
              raise
            end
          end
        ensure
          cleanup_shutdown_pipe(shutdown_pipe)
          cleanup_listener
          @status = :Shutdown
          @logger.info "going to shutdown ..."
          thgroup.list.each{|th| th.join if th[:WEBrickThread] }
          call_callback(:StopCallback)
          @logger.info "#{self.class}#start done."
          @status = :Stop
        end
      }
    end

    ##
    # Stops the server from accepting new connections.

    def stop
      if @status == :Running
        @status = :Shutdown
      end
    end

    ##
    # Shuts down the server and all listening sockets.  New listeners must be
    # provided to restart the server.

    def shutdown
      stop

      shutdown_pipe = @shutdown_pipe # another thread may modify @shutdown_pipe.
      if shutdown_pipe
        if !shutdown_pipe[1].closed?
          begin
            shutdown_pipe[1].close
          rescue IOError # closed by another thread.
          end
        end
      end
    end

    ##
    # You must subclass GenericServer and implement \#run which accepts a TCP
    # client socket

    def run(sock)
      @logger.fatal "run() must be provided by user."
    end

    private

    # :stopdoc:

    ##
    # Accepts a TCP client socket from the TCP server socket +svr+ and returns
    # the client socket.

    def accept_client(svr)
      sock = nil
      begin
        sock = svr.accept
        sock.sync = true
        Utils::set_non_blocking(sock)
        Utils::set_close_on_exec(sock)
      rescue Errno::ECONNRESET, Errno::ECONNABORTED,
             Errno::EPROTO, Errno::EINVAL
      rescue StandardError => ex
        msg = "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
        @logger.error msg
      end
      return sock
    end

    ##
    # Starts a server thread for the client socket +sock+ that runs the given
    # +block+.
    #
    # Sets the socket to the <code>:WEBrickSocket</code> thread local variable
    # in the thread.
    #
    # If any errors occur in the block they are logged and handled.

    def start_thread(sock, &block)
      Thread.start{
        begin
          Thread.current[:WEBrickSocket] = sock
          begin
            addr = sock.peeraddr
            @logger.debug "accept: #{addr[3]}:#{addr[1]}"
          rescue SocketError
            @logger.debug "accept: <address unknown>"
            raise
          end
          call_callback(:AcceptCallback, sock)
          block ? block.call(sock) : run(sock)
        rescue Errno::ENOTCONN
          @logger.debug "Errno::ENOTCONN raised"
        rescue ServerError => ex
          msg = "#{ex.class}: #{ex.message}\n\t#{ex.backtrace[0]}"
          @logger.error msg
        rescue Exception => ex
          @logger.error ex
        ensure
          @tokens.push(nil)
          Thread.current[:WEBrickSocket] = nil
          if addr
            @logger.debug "close: #{addr[3]}:#{addr[1]}"
          else
            @logger.debug "close: <address unknown>"
          end
          sock.close unless sock.closed?
        end
      }
    end

    ##
    # Calls the callback +callback_name+ from the configuration with +args+

    def call_callback(callback_name, *args)
      if cb = @config[callback_name]
        cb.call(*args)
      end
    end

    def setup_shutdown_pipe
      if !@shutdown_pipe
        @shutdown_pipe = IO.pipe
      end
      @shutdown_pipe
    end

    def cleanup_shutdown_pipe(shutdown_pipe)
      @shutdown_pipe = nil
      shutdown_pipe.each {|io|
        if !io.closed?
          begin
            io.close
          rescue IOError # another thread closed io.
          end
        end
      }
    end

    def cleanup_listener
      @listeners.each{|s|
        if @logger.debug?
          addr = s.addr
          @logger.debug("close TCPSocket(#{addr[2]}, #{addr[1]})")
        end
        begin
          s.shutdown
        rescue Errno::ENOTCONN
          # when `Errno::ENOTCONN: Socket is not connected' on some platforms,
          # call #close instead of #shutdown.
          # (ignore @config[:ShutdownSocketWithoutClose])
          s.close
        else
          unless @config[:ShutdownSocketWithoutClose]
            s.close
          end
        end
      }
      @listeners.clear
    end
  end    # end of GenericServer
end