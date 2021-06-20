module SHINK_LIBRARY
  module SuDb
    Sketchup::require 'su_db/base_db'
    Sketchup::require 'su_db/config'
    Sketchup::require 'su_db/auto_save_db'
    Sketchup::require 'su_db/hash_db'
    Sketchup::require 'su_db/array_db'
    Sketchup::require 'su_db/open_struct_array'
    Sketchup::require 'su_db/table'
    OSArray = OpenStructArray
  end
end
