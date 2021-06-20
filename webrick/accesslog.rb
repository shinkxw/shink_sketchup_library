module Shink::WEBrick
  module AccessLog

    ##
    # Raised if a parameter such as %e, %i, %o or %n is used without fetching
    # a specific field.

    class AccessLogError < StandardError; end

    ##
    # The Common Log Format's time format

    CLF_TIME_FORMAT     = "[%d/%b/%Y:%H:%M:%S %Z]"

    ##
    # Common Log Format

    COMMON_LOG_FORMAT   = "%h %l %u %t \"%r\" %s %b"

    ##
    # Short alias for Common Log Format

    CLF                 = COMMON_LOG_FORMAT

    ##
    # Referer Log Format

    REFERER_LOG_FORMAT  = "%{Referer}i -> %U"

    ##
    # User-Agent Log Format

    AGENT_LOG_FORMAT    = "%{User-Agent}i"

    ##
    # Combined Log Format

    COMBINED_LOG_FORMAT = "#{CLF} \"%{Referer}i\" \"%{User-agent}i\""

    module_function

    def setup_params(config, req, res)
      params = Hash.new("")
      params["a"] = req.peeraddr[3]
      params["b"] = res.sent_size
      params["e"] = ENV
      params["f"] = res.filename || ""
      params["h"] = req.peeraddr[2]
      params["i"] = req
      params["l"] = "-"
      params["m"] = req.request_method
      params["n"] = req.attributes
      params["o"] = res
      params["p"] = req.port
      params["q"] = req.query_string
      params["r"] = req.request_line.sub(/\x0d?\x0a\z/o, '')
      params["s"] = res.status       # won't support "%>s"
      params["t"] = req.request_time
      params["T"] = Time.now - req.request_time
      params["u"] = req.user || "-"
      params["U"] = req.unparsed_uri
      params["v"] = config[:ServerName]
      params
    end

    ##
    # Formats +params+ according to +format_string+ which is described in
    # setup_params.

    def format(format_string, params)
      format_string.gsub(/\%(?:\{(.*?)\})?>?([a-zA-Z%])/){
         param, spec = $1, $2
         case spec[0]
         when ?e, ?i, ?n, ?o
           raise AccessLogError,
             "parameter is required for \"#{spec}\"" unless param
           (param = params[spec][param]) ? escape(param) : "-"
         when ?t
           params[spec].strftime(param || CLF_TIME_FORMAT)
         when ?p
           case param
           when 'remote'
             escape(params["i"].peeraddr[1].to_s)
           else
             escape(params["p"].to_s)
           end
         when ?%
           "%"
         else
           escape(params[spec].to_s)
         end
      }
    end

    ##
    # Escapes control characters in +data+

    def escape(data)
      if data.tainted?
        data.gsub(/[[:cntrl:]\\]+/) {$&.dump[1...-1]}.untaint
      else
        data
      end
    end
  end
end
