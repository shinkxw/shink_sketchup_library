module SHINK_LIBRARY
  class UID
    CLOCK_MULTIPLIER = 10000000
    VERSION_CLOCK = 0x0100

    def self.generate;new.generate end

    def initialize
      @drift = 0
      @last_clock = (Time.now.to_f * CLOCK_MULTIPLIER).to_i
      @mutex = Mutex.new
      @sequence = rand 0x10000
    end

    def generate
      clock = @mutex.synchronize do
        clock = (Time.new.to_f * CLOCK_MULTIPLIER).to_i & 0xFFFFFFFFFFFFFFF0

        if clock > @last_clock then
          @drift = 0
          @last_clock = clock
        elsif clock == @last_clock then
          drift = @drift += 1

          if drift < 10000 then
            @last_clock += 1
          else
            Thread.pass
            nil
          end
        else
          next_sequence
          @last_clock = clock
        end
      end until clock

      '%08x-%04x-%04x-%04x' % [
        clock        & 0xFFFFFFFF,
        (clock >> 32) & 0xFFFF,
        ((clock >> 48) & 0xFFFF | VERSION_CLOCK),
        @sequence      & 0xFFFF
      ]
    end

    def next_sequence
      @sequence += 1
      @last_clock = (Time.now.to_f * CLOCK_MULTIPLIER).to_i
      @drift = 0
    end
  end
end
