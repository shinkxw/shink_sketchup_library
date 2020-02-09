$LOAD_PATH.unshift(File.dirname(__FILE__))
require "sketchup"
require 'uri'
require 'csv'
require 'time'
require 'json'
require 'zlib'
require 'thread'
require 'ostruct'
require 'net/http'
require 'fileutils'

Sketchup::require('constants')#常量表
#补充SU可能缺失的文件
$LOAD_PATH.push("#{File.dirname(__FILE__)}/su_supplement/su_#{SHINK_LIBRARY::SuVersion}")

require 'webrick'

Sketchup::require('base64')#加载高版本的base64库
Sketchup::require('shink_library')#注入基础库的方法
Sketchup::require('load_gems')#加载gem的方法
Sketchup::require('su_puts')#跨线程输出到控制台
Sketchup::require('su_run_js')#跨线程跨窗口执行js
Sketchup::require('su_entity_attribute')#跨线程设置对象属性
Sketchup::require('su_db')#数据存储
Sketchup::require('path_helper')#打开电脑路径相关
Sketchup::require('circulator')#轮询器
Sketchup::require('entity_traversal')#SU对象遍历
Sketchup::require('uid')#不重复id生成器
Sketchup::require('entity_uid')#SU对象与不重复id关联及查找
Sketchup::require('reuse_service')#公用服务调度
Sketchup::require('api_server')#api及文件服务器
Sketchup::require('shink_browser')#加强回调的网页对话框

#去除基础库文件被加载的记录
$LOAD_PATH.delete(File.dirname(__FILE__))
$LOADED_FEATURES.replace($LOADED_FEATURES.find_all{|p| !p.include?('shink_')})

module SHINK_LIBRARY
  VERSION = '0.0.1'.freeze
  # load_gem('zip')
end
