# frozen-string-literal: true

require "_down/version"
require "_down/net_http"

module Down
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

Down.backend Down::NetHttp
