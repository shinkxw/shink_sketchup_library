module SHINK_LIBRARY
  extend self
  #将库注入至指定模块, 包括方法, 常量
  def self.inject_to_module(mod)
    mod.extend(self)
    constants.each do |const_name|
      const = const_get(const_name)
      mod.const_set(const_name, const)
    end
  ensure
    Object.send(:remove_const, 'SHINK_LIBRARY') if Object.const_defined?('SHINK_LIBRARY', false)
  end
end
