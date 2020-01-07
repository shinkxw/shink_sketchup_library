module SHINK_LIBRARY
  module SuEntityAttribute
    module_function

    @hash = {}
    @last_add_time_stamp = 0
    @last_add_time_stamp_hash = {}
    @timer = UI.start_timer(0.05, true) {self.set_all} if @timer.nil?
    def add_set(entity, section, key, value)
      add_time_stamp = get_add_time_stamp
      if Thread.current == MainThread
        set(entity, section, key, value, add_time_stamp)
      else
        arr_key = [entity, section, key]
        @hash[arr_key] = [value, add_time_stamp]
      end
    end

    def get_add_time_stamp
      time_stamp = Time.now.to_f
      if time_stamp <= @last_add_time_stamp
        @last_add_time_stamp += 0.00001
      else
        @last_add_time_stamp = time_stamp
      end
    end

    def set_all
      @hash, old_hash = {}, @hash
      old_hash.each do |(entity, section, key), (value, add_time_stamp)|
        set(entity, section, key, value, add_time_stamp)
      end
    end

    def set(entity, section, key, value, add_time_stamp)
      arr_key = [entity, section, key]
      last_add_time_stamp = @last_add_time_stamp_hash[arr_key]
      return if last_add_time_stamp && last_add_time_stamp > add_time_stamp#验证时间戳
      entity.set_attribute(section, key, value)
      @last_add_time_stamp_hash[arr_key] = add_time_stamp
    end
  end
end
