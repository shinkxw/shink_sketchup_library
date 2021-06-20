module Shink::WEBrick
  module HTMLUtils

    ##
    # Escapes &, ", > and < in +string+

    def escape(string)
      return "" unless string
      str = string.b
      str.gsub!(/&/n, '&amp;')
      str.gsub!(/\"/n, '&quot;')
      str.gsub!(/>/n, '&gt;')
      str.gsub!(/</n, '&lt;')
      str.force_encoding(string.encoding)
    end
    module_function :escape

  end
end
