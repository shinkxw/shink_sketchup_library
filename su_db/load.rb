module Shink::BaseLibrary
  module SuDb
    dir = File.dirname(__FILE__)
    Sketchup::require "#{dir}/base_db"
    Sketchup::require "#{dir}/config"
    Sketchup::require "#{dir}/auto_save_db"
    Sketchup::require "#{dir}/hash_db"
    Sketchup::require "#{dir}/array_db"
    Sketchup::require "#{dir}/open_struct_array"
    Sketchup::require "#{dir}/table"
    OSArray = OpenStructArray
  end
end
