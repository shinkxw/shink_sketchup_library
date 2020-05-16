# frozen-string-literal: true

gem "http", ">= 2.1.0", "< 4"

require "http"

require "_down/backend"

require "tempfile"
require "cgi"
require "base64"

module Down
  class Http < Backend
    def initialize(options = {}, &block)
      if options.is_a?(HTTP::Client)
        warn "[Down] Passing an HTTP::Client object to Down::Http#initialize is deprecated and won't be supported in Down 5. Use the block initialization instead."
        options = options.default_options.to_hash
      end

      @method = options.delete(:method) || :get
      @client = HTTP
        .headers("User-Agent" => "Down/#{Down::VERSION}")
        .follow(max_hops: 2)
        .timeout(connect: 30, write: 30, read: 30)

      @client = HTTP::Client.new(@client.default_options.merge(options)) if options.any?
      @client = block.call(@client) if block
    end

    def download(url, max_size: nil, progress_proc: nil, content_length_proc: nil, destination: nil, **options, &block)
      response = request(url, **options, &block)

      content_length_proc.call(response.content_length) if content_length_proc && response.content_length

      if max_size && response.content_length && response.content_length > max_size
        raise Down::TooLarge, "file is too large (max is #{max_size/1024/1024}MB)"
      end

      extname  = File.extname(response.uri.path)
      tempfile = Tempfile.new(["down-http", extname], binmode: true)

      stream_body(response) do |chunk|
        tempfile.write(chunk)
        chunk.clear # deallocate string

        progress_proc.call(tempfile.size) if progress_proc

        if max_size && tempfile.size > max_size
          raise Down::TooLarge, "file is too large (max is #{max_size/1024/1024}MB)"
        end
      end

      tempfile.open # flush written content

      tempfile.extend Down::Http::DownloadedFile
      tempfile.url     = response.uri.to_s
      tempfile.headers = response.headers.to_h

      download_result(tempfile, destination)
    rescue
      tempfile.close! if tempfile
      raise
    end

    def open(url, rewindable: true, **options, &block)
      response = request(url, **options, &block)

      Down::ChunkedIO.new(
        chunks:     enum_for(:stream_body, response),
        size:       response.content_length,
        encoding:   response.content_type.charset,
        rewindable: rewindable,
        data:       { status: response.code, headers: response.headers.to_h, response: response },
      )
    end

    private

    def request(url, method: @method, **options, &block)
      response = send_request(method, url, **options, &block)
      response_error!(response) unless response.status.success?
      response
    end

    def send_request(method, url, **options, &block)
      url = process_url(url, options)

      client = @client
      client = block.call(client) if block

      client.request(method, url, options)
    rescue => exception
      request_error!(exception)
    end

    def stream_body(response, &block)
      response.body.each(&block)
    rescue => exception
      request_error!(exception)
    ensure
      response.connection.close unless @client.persistent?
    end

    def process_url(url, options)
      uri = HTTP::URI.parse(url)

      if uri.user || uri.password
        user, pass = uri.user, uri.password
        authorization = "Basic #{Base64.strict_encode64("#{user}:#{pass}")}"
        options[:headers] ||= {}
        options[:headers].merge!("Authorization" => authorization)
        uri.user = uri.password = nil
      end

      uri.to_s
    end

    def response_error!(response)
      args = [response.status.to_s, response: response]

      case response.code
      when 400..499 then raise Down::ClientError.new(*args)
      when 500..599 then raise Down::ServerError.new(*args)
      else               raise Down::ResponseError.new(*args)
      end
    end

    def request_error!(exception)
      case exception
      when HTTP::Request::UnsupportedSchemeError, Addressable::URI::InvalidURIError
        raise Down::InvalidUrl, exception.message
      when HTTP::ConnectionError
        raise Down::ConnectionError, exception.message
      when HTTP::TimeoutError
        raise Down::TimeoutError, exception.message
      when HTTP::Redirector::TooManyRedirectsError
        raise Down::TooManyRedirects, exception.message
      when OpenSSL::SSL::SSLError
        raise Down::SSLError, exception.message
      else
        raise exception
      end
    end

    module DownloadedFile
      attr_accessor :url, :headers

      def original_filename
        Utils.filename_from_content_disposition(headers["Content-Disposition"]) ||
        Utils.filename_from_path(HTTP::URI.parse(url).path)
      end

      def content_type
        HTTP::ContentType.parse(headers["Content-Type"]).mime_type
      end

      def charset
        HTTP::ContentType.parse(headers["Content-Type"]).charset
      end
    end
  end
end
