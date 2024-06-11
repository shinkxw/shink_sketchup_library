require 'sketchup'
require 'uri'
require 'csv'
require 'time'
require 'json'
require 'zlib'
require 'thread'
require 'ostruct'
require 'net/http'
require 'fileutils'

module Shink
  def self.has_const?(const);Shink.const_defined?(const, false) end
  dir = File.dirname(__FILE__)
  Sketchup::require("#{dir}/webrick/load") if !has_const?('WEBrick')#加载自带的webrick
  Sketchup::require("#{dir}/base64") if !has_const?('Base64')#加载高版本的base64库
  Sketchup::require("#{dir}/su_puts") if !has_const?('SuPuts')#跨线程输出到控制台
  Sketchup::require("#{dir}/su_run_js") if !has_const?('SuRunJs')#跨线程跨窗口执行js
  Sketchup::require("#{dir}/su_entity_attribute") if !has_const?('SuEntityAttribute')#跨线程设置对象属性

  module BaseLibrary
    dir = File.dirname(__FILE__)
    Sketchup::require("#{dir}/constants")#常量表
    Sketchup::require("#{dir}/base_library")#注入基础库的方法
    Sketchup::require("#{dir}/load_gems")#加载gem的方法
    Sketchup::require("#{dir}/su_db/load")#数据存储
    Sketchup::require("#{dir}/path_helper")#打开电脑路径相关
    Sketchup::require("#{dir}/circulator")#轮询器
    Sketchup::require("#{dir}/entity_traversal")#SU对象遍历
    Sketchup::require("#{dir}/uid")#不重复id生成器
    Sketchup::require("#{dir}/entity_uid")#SU对象与不重复id关联及查找
    Sketchup::require("#{dir}/reuse_service")#公用服务调度
    Sketchup::require("#{dir}/api_server")#api及文件服务器
    Sketchup::require("#{dir}/shink_dialog")#加强回调的网页对话框(谷歌内核)
    Sketchup::require("#{dir}/shink_browser")#加强回调的网页对话框

    Base64 = Shink::Base64
    SuRunJs = Shink::SuRunJs
    SuEntityAttribute = Shink::SuEntityAttribute
    VERSION = '0.3.1'.freeze
  end
end
