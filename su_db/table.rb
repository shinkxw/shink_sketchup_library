module SHINK_LIBRARY
  module SuDb
    #表内保存的类需提供以下方法
    #从hash新建实例的类方法, 使用new_method参数提供
    #to_h: 转换为hash的实例方法
    #_id && _id=: _id获取与设置的实例方法
    class Table
      def self.new_by_key(key, mode = :file, klass = OpenStruct, new_method = 'new', section_size = 50, &block)
        new(SuDb.get_section, key, mode, klass, new_method, section_size, &block)
      end
      include Enumerable

      def initialize(section, key, mode, klass, new_method, section_size, &block)
        @section, @key, @mode = section, key, mode
        @klass, @new_method = klass, new_method
        @config = get_config(section_size)
        init_section
        each(&block) if block
      end
      def get_config(section_size)
        config = Config.new_by_key("#{@key}_table_config", @mode)
        unless config.is_init
          config.max_id = 0
          config.section_size = section_size
          config.is_init = true
        end
        return config
      end
      def init_section
        @section_hash, @section_arr = {}, []
        max_section_id = get_section_id(@config.max_id)
        1.upto(max_section_id) do |section_id|
          section_key = get_section_key(section_id)
          add_section(section_key)
        end
      end
      def length;@section_arr.map{|section| section.length}.inject(:+) end
      def clear(section_size = nil)
        @section_arr.each{|section| section.clear}
        @config.max_id = 0
        @config.section_size = section_size if section_size
      end
      def drop_last
        remove_by_id(@config.max_id)
        @config.max_id -= 1
      end
      def add(obj)
        obj._id = get_new_id
        section = get_section(obj._id)
        section.add(obj)
      end
      def get_new_id;@config.max_id += 1 end
      def update(obj)
        get_section(check_id(obj._id)).save
      end
      def remove(obj)
        remove_by_id(obj._id)
      end
      def remove_by_id(id)
        id = id.to_i
        section = get_section(check_id(id))
        section.remove_by_id(id)
      end
      def check_id(id)
        raise 'id有误' if @config.max_id < id
        id
      end
      def find_obj(id);find{|obj| obj._id == id} end
      def get_section(obj_id)
        section_key = get_section_key(get_section_id(obj_id))
        if @section_hash.has_key?(section_key)
          @section_hash[section_key]
        else
          add_section(section_key)
        end
      end
      def add_section(section_key)
        section = TableSection.new(@section, section_key, @mode, @klass, @new_method)
        @section_hash[section_key] = section
        @section_arr << section
        return section
      end
      def get_section_key(section_id);"#{@key}_table_#{section_id}" end
      def get_section_id(obj_id);(obj_id / @config.section_size) + 1 end
      def each(&proc);@section_arr.each{|section| section.each(&proc)} end
      def reverse
        Enumerator.new do |result|
          @section_arr.reverse_each do |section|
            section.reverse_each do |obj|
              result << obj
            end
          end
        end
      end
    end

    # describe Table do

    #   it "can work" do
    #     model_2 = Table.new_by_key('table_test_2', :model, TableTestObj, 'new_by_hash', 2)
    #     file_2 = Table.new_by_key('table_test_2', :file, TableTestObj, 'new_by_hash', 2)
    #     [model_2, file_2].each do |table|
    #       #clear
    #       table.clear
    #       table.length.must_equal(0)
    #       #add
    #       table.add(TableTestObj.new('shink'))
    #       table.add(TableTestObj.new('hahaha'))
    #       table.length.must_equal(2)
    #       #drop_last
    #       table.drop_last
    #       table.length.must_equal(1)
    #       table.add(TableTestObj.new('abc'))
    #       table.add(TableTestObj.new('ghj'))
    #       table.length.must_equal(3)
    #       #reverse
    #       table.reverse.first.name.must_equal('ghj')
    #       #update
    #       obj = table.find{|obj| obj._id == 2}
    #       obj.name.must_equal('abc')
    #       obj.name = 'def'
    #       table.update(obj)
    #       table.find{|obj| obj._id == 2}.name.must_equal('def')
    #       #remove
    #       table.remove(obj)
    #       table.length.must_equal(2)
    #       #remove_by_id
    #       table.remove_by_id(3)
    #       table.length.must_equal(1)
    #     end
    #   end

      # it "speed test" do
      #   global_1 = Table.new_by_key('table_test_1', :global, TableTestObj, 'new_by_hash', 1)
      #   global_10 = Table.new_by_key('table_test_10', :global, TableTestObj, 'new_by_hash', 10)
      #   global_20 = Table.new_by_key('table_test_20', :global, TableTestObj, 'new_by_hash', 20)
      #   global_50 = Table.new_by_key('table_test_50', :global, TableTestObj, 'new_by_hash', 50)
      #   global_100 = Table.new_by_key('table_test_100', :global, TableTestObj, 'new_by_hash', 100)
      #   model_1 = Table.new_by_key('table_test_1', :model, TableTestObj, 'new_by_hash', 1)
      #   model_10 = Table.new_by_key('table_test_10', :model, TableTestObj, 'new_by_hash', 10)
      #   model_20 = Table.new_by_key('table_test_20', :model, TableTestObj, 'new_by_hash', 20)
      #   model_50 = Table.new_by_key('table_test_50', :model, TableTestObj, 'new_by_hash', 50)
      #   model_100 = Table.new_by_key('table_test_100', :model, TableTestObj, 'new_by_hash', 100)
      #   file_1 = Table.new_by_key('table_test_1', :file, TableTestObj, 'new_by_hash', 1)
      #   file_10 = Table.new_by_key('table_test_10', :file, TableTestObj, 'new_by_hash', 10)
      #   file_20 = Table.new_by_key('table_test_20', :file, TableTestObj, 'new_by_hash', 20)
      #   file_50 = Table.new_by_key('table_test_50', :file, TableTestObj, 'new_by_hash', 50)
      #   file_100 = Table.new_by_key('table_test_100', :file, TableTestObj, 'new_by_hash', 100)
      #   {global_100: global_100, global_50: global_50, global_20: global_20, global_10: global_10, global_1: global_1,
      #     model_100: model_100, model_50: model_50, model_20: model_20, model_10: model_10, model_1: model_1,
      #     file_100: file_100, file_50: file_50, file_20: file_20, file_10: file_10, file_1: file_1}.each do |mode, table|
      #     table.clear
      #     max_num = 1000
      #     #add
      #     cost_time = cost_time do
      #       1.upto(max_num) do |i|
      #         table.add(TableTestObj.new(i))
      #       end
      #     end
      #     p "mode #{mode} Table add #{max_num} cost #{cost_time}"
      #     table.find_obj(153).name.must_equal(153)
      #     table.find_obj(650).name.must_equal(650)
      #     table.length.must_equal(max_num)
      #     #update
      #     cost_time = cost_time do
      #       1.upto(max_num) do |i|
      #         obj = table.find_obj(i)
      #         obj.name = i * 2
      #         table.update(obj)
      #       end
      #     end
      #     p "mode #{mode} Table update #{max_num} cost #{cost_time}"
      #     table.find_obj(153).name.must_equal(306)
      #     table.find_obj(650).name.must_equal(1300)
      #     #remove_by_id
      #     cost_time = cost_time do
      #       1.upto(max_num) do |i|
      #         table.remove_by_id(i)
      #       end
      #     end
      #     p "mode #{mode} Table remove #{max_num} cost #{cost_time}"
      #     table.length.must_equal(0)
      #   end
      # end
    # end

    class TableSection < BaseDb
      def self.new_by_key(key, mode = :file, klass = OpenStruct, new_method = 'new')
        new(SuDb.get_section, key, mode, klass, new_method)
      end
      include Enumerable

      def initialize(section, key, mode, klass, new_method)
        @klass, @new_method = klass, new_method
        super(section, key, mode)
      end
      def load(data)
        arr = data ? data : []
        arr.map{|h| @klass.send(@new_method, h).tap{|obj| obj._id = h['_id'] if obj}}.compact
      end
      def length;@obj.length end
      def clear
        @obj.clear
        save
      end
      def add(obj)
        @obj << obj
        save
        obj
      end
      def remove_by_id(id)
        @obj.delete_if{|obj| obj._id == id}
        save
      end
      def each(&proc);@obj.each(&proc) end
      def reverse_each(&proc);@obj.reverse_each(&proc) end
      def find_obj(id);@obj.find{|obj| obj._id == id} end
      def to_json;@obj.map{|obj| obj.to_h.tap{|h| h[:_id] = obj._id}}.to_json end
    end

    class TableTestObj
      def self.new_by_hash(hash);new(hash['name']) end
      attr_accessor :_id, :name
      def initialize(name);@name = name end
      def to_h;{name: @name} end
    end

    # describe TableSection do
    #   before do
    #     @model = TableSection.new_by_key('table_section_test', :model, TableTestObj, 'new_by_hash')
    #     @file = TableSection.new_by_key('table_section_test', :file, TableTestObj, 'new_by_hash')
    #   end

    #   it "can work" do
    #     [@model, @file].each do |ts|
    #       #clear
    #       ts.clear
    #       ts.reload
    #       ts.length.must_equal(0)
    #       #add
    #       obj1 = TableTestObj.new('shink')
    #       obj2 = TableTestObj.new('abc')
    #       obj1._id, obj2._id = 1, 2
    #       ts.add(obj1)
    #       ts.length.must_equal(1)
    #       ts.add(obj2)
    #       ts.reload
    #       ts.length.must_equal(2)
    #       #update
    #       obj = ts.find_obj(2)
    #       obj.name.must_equal('abc')
    #       obj.name = 'def'
    #       ts.save
    #       ts.reload
    #       ts.find_obj(2).name.must_equal('def')
    #       #remove
    #       ts.remove_by_id(obj._id)
    #       ts.reload
    #       ts.length.must_equal(1)
    #     end
    #   end
    # end
  end
end
