module Shink::BaseLibrary
  extend self
  #将库注入至指定模块, 包括方法, 常量
  def inject_to_module(mod)
    mod.extend(self)
    constants.each do |const_name|
      const = const_get(const_name)
      mod.const_set(const_name, const)
    end
  ensure
    Shink.send(:remove_const, 'BaseLibrary') if Shink.has_const?('BaseLibrary')
    #去除基础库文件被加载的记录
    $LOADED_FEATURES.replace($LOADED_FEATURES.find_all{|p| !p.include?('shink_sketchup_library')})
  end
end
