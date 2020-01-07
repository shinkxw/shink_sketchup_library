module SHINK_LIBRARY
  class ApiServer
    def initialize(port, document_root = nil, log = nil)
      @port, @document_root = port, document_root
      @log = log.is_a?(File) ? log : File.open(log, 'w+') if log
      @api_hash = {}
    end

    def set_default_content_type(content_type);@content_type = content_type end
    def default_content_type;@content_type || "application/json;charset=utf-8" end

    def add_api(path, &block)
      @api_hash[path] = block
    end

    def new_server(document_root)
      log = WEBrick::Log.new(@log)
      access_log = [[@log, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]
      server = WEBrick::HTTPServer.new(Port: @port, DocumentRoot: document_root, Logger: log, AccessLog: access_log)

      @api_hash.each do |path, proc|
        server.mount_proc path do |req, res|
          res["Access-Control-Allow-Origin"] = "*"
          begin
            query_hash = {}
            req.query.each do |k, v|
              query_hash[k] = v.force_encoding('UTF-8').to_s
            end
            query = OpenStruct.new(query_hash)
            body, status, content_type = proc.call(query)
            res.status = status if status
            res.body = body
            res.content_type = content_type || default_content_type
          rescue ParamError => param_error
            res.status, res.body = 400, param_error.message
          rescue HTTPFail => http_fail
            res.status, res.body = http_fail.status, http_fail.body
          rescue => err
            output(err.class)
            output(err.message)
            output(err.backtrace)
            res.status, res.body = 400, err.message
          end
        end
      end
      server
    end

    def start(document_root = @document_root)
      server = new_server(document_root)
      begin
        server.start
      rescue => e
        output(e.message)
      ensure
        server.shutdown
      end
    end
  end

  class HTTPFail < StandardError
    attr_reader :status, :body, :uri
    def initialize(arr)
      @status, @body, @uri = arr
    end
    def to_s;"#{@uri} #{@status}: #{@body}" end
  end

  class ParamError < Exception;end
end
