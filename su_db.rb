module SHINK_LIBRARY
  module SuDb
    require_relative('su_db/base_db')
    require_relative('su_db/config')
    require_relative('su_db/auto_save_db')
    require_relative('su_db/hash_db')
    require_relative('su_db/array_db')
    require_relative('su_db/open_struct_array')
    require_relative('su_db/table')
    OSArray = OpenStructArray
  end
end
