# frozen-string-literal: true

require "open-uri"
begin
  require "net/https"
rescue Exception
end
require "tempfile"
require "fileutils"
require "cgi"

dir = "#{File.dirname(__FILE__)}/_down"
Sketchup::require "#{dir}/chunked_io"
Sketchup::require "#{dir}/errors"
Sketchup::require "#{dir}/utils"
Sketchup::require "#{dir}/backend"
Sketchup::require "#{dir}/net_http"

module Shink::BaseLibrary
  module Down
    Down = self
    VERSION = "4.5.0"
    module_function

    def download(*args, &block)
      backend.download(*args, &block)
    end

    def open(*args, &block)
      backend.open(*args, &block)
    end

    def backend(value = nil)
      if value.is_a?(Symbol)
        require "_down/#{value}"
        @backend = Down.const_get(value.to_s.split("_").map(&:capitalize).join)
      elsif value
        @backend = value
      else
        @backend
      end
    end
  end

  Down.backend(Down::NetHttp)
end
