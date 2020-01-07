module SHINK_LIBRARY
  module SuDb
    def self.set_section(section);@section = section end
    def self.get_section;@section ? @section : 'SU_DB' end

    class BaseDb
      def self.new_by_key(key, mode = :file);new(SuDb.get_section, key, mode) end
      attr_reader :section, :key, :mode
      #mode: model 仅当前模型打开时, file 存贮数据在文件中
      def initialize(section, key, mode)
        @section, @key, @mode = section, key, mode
        @adapter = get_adapter(mode, section, key)
        reload
      end
      def reload;@obj = load(get_data) end
      def get_data
        deflate_str = @adapter.get_str
        return nil if deflate_str.nil?
        json = Zlib::Inflate.inflate(deflate_str)
        json ? JSON.parse(json) : nil
      end
      def get_adapter(mode, section, key)
        case mode
        when :global
          GlobalAdapter.new(section, key)
        when :model
          ModelAdapter.new(section, key)
        when Sketchup::Entity
          EntityAdapter.new(mode, section, key)
        when :file
          FileAdapter.new(section, key)
        else
          raise "未知的适配器类型: #{mode}"
        end
      end
      def save
        json = to_json
        deflate_str = deflate(json)
        @adapter.save_str(deflate_str)
        # cost_time = cost_time{@adapter.save_str(deflate_str)}
        # output "#{@key}   #{cost_time}   #{json.size}   #{deflate_str.size}"
        nil
      end
      def deflate(str)
        Zlib::Deflate.deflate(str)
      end
      def to_json;@obj.to_json end
    end

    class Adapter
      def initialize(section, key);@section, @key = section, key end
      def get_str;end
      def save_str(str);end
    end

    class GlobalAdapter < Adapter
      def get_str
        Sketchup.read_default(@section, @key)
      end
      def save_str(str)
        str = str.inspect[1..-2]
        Sketchup.write_default(@section, @key, str)
      end
    end

    class EntityAdapter < Adapter
      def initialize(entity, section, key)
        @entity = entity
        super(section, key)
      end
      def get_str
        str = @entity.get_attribute(@section, @key)
        str ? eval(str) : nil
      end
      def save_str(str)
        SuEntityAttribute.add_set(@entity, @section, @key, str.inspect)
      end
    end

    class ModelAdapter < Adapter
      def get_str
        str = Sketchup.active_model.get_attribute(@section, @key)
        str ? eval(str) : nil
      end
      def save_str(str)
        SuEntityAttribute.add_set(Sketchup.active_model, @section, @key, str.inspect)
      end
    end

    class FileAdapter < Adapter
      def initialize(section, key)
        super
        if File.exist?(file_path)
          if file_test?(file_path)
            backup_file if backup_file_list.empty?#备份文件如果未备份过
          else
            FileUtils.remove_file(file_path)#删除损坏文件
            list = backup_file_list
            while n = list.shift
              backup_file_path = "#{backup_directory}/#{n}"
              if file_test?(backup_file_path)
                FileUtils.cp(backup_file_path, file_path)
                break
              end
            end
          end
        end
      end
      def get_str
        File.open(file_path, "rb"){|f| f.read} if File.exist?(file_path)
      end
      def save_str(str)
        File.open(file_path, "wb"){|f| f.syswrite(str)}
        backup_file#备份
      end
      def file_test?(path)#验证文件能否使用
        Zlib::Inflate.inflate(File.open(path, "rb"){|f| f.read}) rescue false
      end
      def backup_file
        @last_backup_time = get_time_stamp
        backup_time = @last_backup_time
        backup_file_path = "#{backup_directory}/#{Time.now.to_i}"
        if Thread.current == MainThread
          UI.start_timer(3) do
            FileUtils.cp(file_path, backup_file_path) if backup_time == @last_backup_time
          end
        else
          FileUtils.cp(file_path, backup_file_path)
        end
      end
      def backup_file_list
        list = Dir.foreach(backup_directory).drop_while{|n| n.start_with?('.')}.map(&:to_i).sort.reverse
        if list.length > 7#备份文件过多时删除较早的文件
          list[7..-1].each{|n| FileUtils.remove_file("#{backup_directory}/#{n}")}
          list = list.first(7)
        end
        list
      end
      def file_path
        @file_path ||= "#{db_directory}/#{@section}_#{@key}.db"
      end
      def backup_directory
        return @backup_directory if @backup_directory
        backup_directory = "#{db_directory}/bak/#{@section}_#{@key}"
        FileUtils.mkdir_p(backup_directory) unless Dir.exist?(backup_directory)
        @backup_directory = backup_directory
      end
      def db_directory
        return @db_directory if @db_directory
        db_directory = "#{DocumentsPath}/DUC/SU_#{SuVersion}_db"
        FileUtils.mkdir_p(db_directory) unless Dir.exist?(db_directory)
        @db_directory = db_directory
      end
      def get_time_stamp
        @last_time_stamp ||= 0
        time_stamp = Time.now.to_f
        if time_stamp <= @last_time_stamp
          @last_time_stamp += 0.00001
        else
          @last_time_stamp = time_stamp
        end
      end
    end
  end
end
