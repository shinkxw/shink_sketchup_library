module SHINK_LIBRARY
  module SuDb
    class ArrayDb < AutoSaveDb
      def load(data);data ? data : [] end
      def to_json;@obj.to_json end
      def need_save_mathods
        %i(<< push pop clear shift unshift insert []= delete delete_if replace)
      end
    end

    # describe ArrayDb do
    #   before do
    #     @model = ArrayDb.new_by_key('array_db_test', :model)
    #     @file = ArrayDb.new_by_key('array_db_test', :file)
    #   end

    #   it "can work" do
    #     [@model, @file].each do |arr|
    #       arr.clear
    #       arr.length.must_equal(0)
    #       arr << 'a'
    #       arr[0].must_equal('a')
    #       arr.push('b')
    #       arr[1].must_equal('b')
    #       arr.unshift('c')
    #       arr[0].must_equal('c')
    #       arr.reload
    #       arr.length.must_equal(3)
    #       arr.delete('b')
    #       arr.length.must_equal(2)
    #       arr.replace([])
    #       arr.length.must_equal(0)
    #     end
    #   end
    # end
  end
end
