module SHINK_LIBRARY
  module SuDb
    class HashDb < AutoSaveDb
      def load(data);data ? data : {} end
      def [](key);@obj[key] end
      def need_save_mathods;%i([]= replace) end
    end

    # describe HashDb do
    #   before do
    #     @model = HashDb.new_by_key('hash_db_test', :model)
    #     @file = HashDb.new_by_key('hash_db_test', :file)
    #   end

    #   it "can work" do
    #     [@model, @file].each do |hash|
    #       #set value
    #       rand_num = rand(100)
    #       hash['num'] = rand_num
    #       Thread.new{hash['str'] = 'abc'}
    #       sleep 0.01
    #       hash['str'].must_equal('abc')
    #       sleep 0.1
    #       hash['arr'] = [1, 3, 5]
    #       hash['hash'] = {name: 'test'}
    #       hash.reload
    #       hash['num'].must_equal(rand_num)
    #       hash['str'].must_equal('abc')
    #       hash['arr'][1].must_equal(3)
    #       hash['hash']['name'].must_equal('test')
    #       #replace
    #       hash.replace({})
    #       hash.length.must_equal(0)
    #     end
    #   end
    # end
  end
end
