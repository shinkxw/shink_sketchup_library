module SHINK_LIBRARY
  class ShinkDialog < UI::HtmlDialog

    def add_callback(name)
      add_action_callback(name) do |_, json|
        hash = json != nil ? JSON.parse(Zlib::Inflate.inflate(Base64.decode64(json))) : {}
        param = OpenStruct.new(hash)
        begin
          yield _, param
        rescue => e
          output(e.class)
          output(e.message)
          output(e.backtrace)
          UI.messagebox(e.message)
        end
      end
    end

    def show
      set_on_closed{run_after_close}
      super
      set_environment_variables
    end

    def show_modal
      set_on_closed{run_after_close}
      super
      set_environment_variables
    end

    def set_environment_variables
      UI.start_timer(1) do
        execute_script('window.in_su = true')
        execute_script("window.is_windows = #{IsWindows}")
      end
    end

    def set_window_size(width, height)
      set_size(width + 16, height + 38)
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
