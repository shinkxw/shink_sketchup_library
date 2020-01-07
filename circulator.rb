module SHINK_LIBRARY
  class Circulator
    def initialize(gap_sec)
      @id = UI.start_timer(gap_sec, true) do
        result = yield
        if need_stop?(result)
          stop
          @after_stop.call(result) if @after_stop
        end
      end
    end

    def stop;UI.stop_timer(@id) end

    def need_stop?(result)
      @stop_condition ? @stop_condition.call(result) : false
    end

    def set_stop_condition(&block)
      @stop_condition = block
      self
    end

    def after_stop(&block)
      @after_stop = block
      self
    end
  end
end
