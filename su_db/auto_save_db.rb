module SHINK_LIBRARY
  module SuDb
    class AutoSaveDb < BaseDb
      def need_save(method)
        @need_save_mathod_hash ||= Hash[need_save_mathods.map{|s| [s, true]}]
        @need_save_mathod_hash[method]
      end
      def need_save_mathods;[] end
      def method_missing(m, *args, &block)
        result = @obj.send(m, *args, &block)
        save if need_save(m)
        result
      end
    end
  end
end
