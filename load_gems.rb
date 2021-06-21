module Shink::BaseLibrary
  def load_gem(gem_name)
    GemManager.load_gem(gem_name)
  end

  module GemManager
    module_function

    def register_gem(gem_name, load_path)
      @gem_hash ||= {}
      @gem_hash[gem_name] = load_path
    end

    def load_gem(gem_name)
      load_path = @gem_hash[gem_name]
      raise "未找到可加载的gem: #{gem_name}" if load_path.nil?
      Sketchup::require "#{File.dirname(__FILE__)}/gems/#{load_path}"
    end
  end

  GemManager.register_gem('zip', 'rubyzip-1.2.1/_zip')
  GemManager.register_gem('down', 'down-4.5.0/_down')
  GemManager.register_gem('write_xlsx', 'write_xlsx-0.85.7/_write_xlsx')#依赖zip
end
