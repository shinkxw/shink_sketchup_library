module Shink::WEBrick
  Sketchup::require 'webrick/compat'

  VERSION = "1.3.2"

  dir = File.dirname(__FILE__)
  Sketchup::require "#{dir}/httpversion"
  Sketchup::require "#{dir}/httputils"
  Sketchup::require "#{dir}/utils"
  Sketchup::require "#{dir}/log"
  Sketchup::require "#{dir}/config"
  Sketchup::require "#{dir}/server"
  Sketchup::require "#{dir}/accesslog"

  Sketchup::require "#{dir}/htmlutils"
  Sketchup::require "#{dir}/cookie"
  Sketchup::require "#{dir}/httpstatus"
  Sketchup::require "#{dir}/httprequest"
  Sketchup::require "#{dir}/httpresponse"
  Sketchup::require "#{dir}/httpserver"

  Sketchup::require "#{dir}/httpservlet/abstract"
  Sketchup::require "#{dir}/httpservlet/filehandler"
  Sketchup::require "#{dir}/httpservlet/erbhandler"
  Sketchup::require "#{dir}/httpservlet/prochandler"
  Sketchup::require "#{dir}/httpservlet"
end
