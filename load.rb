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
Sketchup::require('shink_library')
Sketchup::require('load_gems')
Sketchup::require('su_puts')#跨线程输出到控制台
Sketchup::require('su_run_js')#跨线程跨窗口执行js
Sketchup::require('su_entity_attribute')#跨线程设置对象属性
Sketchup::require('su_db')#数据存储

#去除基础库文件被加载的记录
$LOADED_FEATURES.replace($LOADED_FEATURES.find_all{|p| !p.include?('shink_')})

module SHINK_LIBRARY
  VERSION = '0.0.1'.freeze
  load_gem('zip')
end
