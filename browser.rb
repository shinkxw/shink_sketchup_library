module SHINK_LIBRARY
  class Browser < UI::WebDialog

    def add_callback(name)
      add_action_callback(name) do |d, json|
        hash = json != '' ? JSON.parse(Zlib::Inflate.inflate(Base64.decode64(json))) : {}
        param = OpenStruct.new(hash)
        begin
          yield d, param
        rescue => e
          output(e.class)
          output(e.message)
          output(e.backtrace)
          UI.messagebox(e.message)
        end
      end
    end

    def show
      set_on_close{run_after_close}
      super do
        execute_script('window.in_su = true')
        execute_script("window.is_windows = #{IsWindows}")
        yield if block_given?
      end
    end

    def show_modal
      set_on_close{run_after_close}
      super do
        execute_script('window.in_su = true')
        execute_script("window.is_windows = #{IsWindows}")
        yield if block_given?
      end
    end

    def hide(now_width, now_height)
      @width_height = [now_width, now_height]
      @min_width_height = [self.min_width, self.min_height]
      self.min_width = 0
      self.min_height = 0
      set_size(0, 0)
    end

    def restore_size
      if @width_height
        self.min_width = @min_width_height.first
        self.min_height = @min_width_height.last
        set_window_size(*@width_height)
        @width_height = nil
      end
    end

    def set_window_size(width, height)
      set_size(width + 16, height + 38)
    end

    def set_window_min_size(width, height)
      self.min_width = width + 16
      self.min_height = height + 38
    end

    def after_close(&block)
      @after_close_block_arr ||= []
      @after_close_block_arr << block
    end

    def run_after_close
      if @after_close_block_arr
        @after_close_block_arr.each{|block| block.call}
        @after_close_block_arr = []
      end
    end
  end
end
