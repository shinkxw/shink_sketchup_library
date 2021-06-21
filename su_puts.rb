module Shink
  module SuPuts
    module_function

    @outputs = []
    @timer = UI.start_timer(1, true) {SuPuts.puts} if @timer.nil?
    def add(str)
      @outputs << str
      str
    end

    def puts
      until @outputs.empty?
        SKETCHUP_CONSOLE.send(:p, @outputs.shift)
      end
    end
  end

  def self.output(str)
    SuPuts.add(str)
  end
end
