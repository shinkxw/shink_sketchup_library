module Shink
  module SuRunJs
    module_function

    @js_arr = []
    @dialog_hash = {}
    @timer = UI.start_timer(0.1, true) {SuRunJs.run} if @timer.nil?
    def add_js(key, js)
      @js_arr << {key: key, js: js}
      js
    end

    def set_web_dialog(key, web_dialog)
      @dialog_hash[key] = web_dialog
    end

    def run
      until @js_arr.empty?
        h = @js_arr.shift
        web_dialog = @dialog_hash[h[:key]]
        web_dialog.execute_script(h[:js]) if web_dialog
      end
    end
  end

  def self.run_js(key, js)
    SuRunJs.add_js(key, js)
  end
end
