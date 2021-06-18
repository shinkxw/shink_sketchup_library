module SHINK_LIBRARY
  module PathHelper
    module_function

    def open_folder_and_select(path)#打开文件夹并选中
      if IsWindows
        system ("Explorer /select, #{path.gsub('/', '\\')}")
      else
        system ("open -R #{path}")
      end
    end

    def open_dir(dir)#打开指定路径
      if IsWindows
        system ("Explorer #{dir.gsub('/', '\\')}")
      else
        system ("open #{dir}")
      end
    end
  end
end
