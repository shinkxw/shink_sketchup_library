module SHINK_LIBRARY
  def load_gem(name)
    GemManager.load_gem(name, [self])
  end

  module GemManager
    module_function

    def register_gem(name, consts, lib_path, load_path, key_path, depend_gems = [], base_path = File.dirname(__FILE__))
      @gem_hash ||= {}
      consts = consts.is_a?(Array) ? consts : [consts]
      hash = {name: name, consts: consts, lib_path: lib_path, load_path: load_path, key_path: key_path, base_path: base_path, depend_gems: depend_gems}
      os = OpenStruct.new(hash)
      @gem_hash[name] = os
    end

    def load_gem(name, to_const_arr)
      os = @gem_hash[name]
      raise "未找到可加载的gem: #{name}" if os.nil?
      hide_consts(os.consts) do
        lib_path = "#{os.base_path}/#{os.lib_path}"
        temporary_load(lib_path, os.key_path){ require "#{lib_path}/#{os.load_path}" }

        os.consts.repeated_permutation(2) do |const_name1, const_name2|
          const1, const2 = Object.const_get(const_name1), Object.const_get(const_name2)
          const1.const_set(const_name2, const2)
        end

        os.depend_gems.each{|gem_name| load_gem(gem_name, os.consts)}
        os.consts.each{|const_name| move_const(const_name, to_const_arr)}
      end
    end

    def temporary_load(lib_path, key_path)
      $LOAD_PATH.unshift(lib_path)
      $LOADED_FEATURES.replace($LOADED_FEATURES.find_all{|p| !p.include?(key_path)})
      yield
    ensure
      $LOADED_FEATURES.replace($LOADED_FEATURES.find_all{|p| !p.include?(key_path)})
      $LOAD_PATH.delete(lib_path)
    end

    def move_const(const_name, to_const_arr, from_module = Object)
      if from_module.const_defined?(const_name)
        const = from_module.const_get(const_name)
        to_const_arr.each do |to_const|
          to_const = to_const.is_a?(String) ? from_module.const_get(to_const) : to_const
          to_const.const_set(const_name, const)
        end
      end
    end

    def hide_consts(cnames, mod = Object)
      const_hash = {}
      cnames.each do |cname|
        const_hash[cname] = mod.send(:remove_const, cname) if mod.const_defined?(cname, false)
      end
      yield
    ensure
      cnames.each do |cname|
        mod.send(:remove_const, cname) if mod.const_defined?(cname, false)
        mod.const_set(cname, const_hash[cname]) if const_hash.has_key?(cname)
      end
    end
  end

  GemManager.register_gem('zip', 'Zip', 'gems/rubyzip-1.2.1/lib', '_zip', '/rubyzip')
  GemManager.register_gem('down', 'Down', 'gems/down-4.5.0/lib', '_down', '/down')
end
