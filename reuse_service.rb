module Shink::BaseLibrary
  class ReuseService
    attr_accessor :name
    def initialize(name, &start_service_proc)
      @name, @start_service_proc = name, start_service_proc
      @status, @users = :close, []
    end

    def is_open?
      return @status == :start
    end

    def add_user(user)
      @users << user unless @users.include?(user)
      start
    end

    def delete_user(user)
      @users.delete(user)
      close if @users.empty?
    end

    def start
      if @status == :close
        @result = @start_service_proc.call
        @status = :start
      end
    end

    def close
      if @status == :start
        @at_close.call(@result) if @at_close
        @status = :close
      end
    end

    def at_close(&block)
      @at_close = block
      self
    end
  end
end
