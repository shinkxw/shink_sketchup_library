module SHINK_LIBRARY
  class ApiServer
    HTTPUtils = WEBrick::HTTPUtils
    HTTPStatus = WEBrick::HTTPStatus

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
            body, status, content_type = proc.call(query, get_body_os(req))
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

      add_local_file_proxy(server)

      server
    end

    def add_local_file_proxy(server)
      server.mount_proc('/lf') do |req, res|
        local_path = req.query['path']
        local_path = Base64.urlsafe_decode64(local_path).force_encoding('UTF-8') if local_path
        if local_path && File.exist?(local_path)
          st = File::stat(local_path)
          mtime = st.mtime
          res['etag'] = sprintf("%x-%x-%x", st.ino, st.size, st.mtime.to_i)

          if not_modified?(req, res, mtime, res['etag'])
            res.body = ''
            raise HTTPStatus::NotModified
          else
            mtype = HTTPUtils::mime_type(local_path, HTTPUtils::DefaultMimeTypes)
            res['content-type'] = mtype
            res['content-length'] = st.size.to_s
            res['last-modified'] = mtime.httpdate
            res.body = File.open(local_path, "rb")
          end
        else
          raise HTTPStatus::NotFound
        end
      end
    end

    def not_modified?(req, res, mtime, etag)
      if ir = req['if-range']
        begin
          return true if Time.httpdate(ir) >= mtime
        rescue
          return true if HTTPUtils::split_header_value(ir).member?(res['etag'])
        end
      end

      return true if (ims = req['if-modified-since']) && Time.parse(ims) >= mtime
      return true if (inm = req['if-none-match']) && HTTPUtils::split_header_value(inm).member?(res['etag'])
      return false
    end

    def get_body_os(req)
      return nil if req.body.nil?
      OpenStruct.new(JSON.parse(req.body))
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
