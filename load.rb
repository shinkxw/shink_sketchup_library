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

Sketchup::require('shink_library')
Sketchup::require('load_gems')

#去除基础库文件被加载的记录
$LOADED_FEATURES.replace($LOADED_FEATURES.find_all{|p| !p.include?('shink_')})

module SHINK_LIBRARY
  VERSION = '0.0.1'.freeze
  load_gem('zip')
end
