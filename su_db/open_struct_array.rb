module SHINK_LIBRARY
  module SuDb
    class OpenStructArray < ArrayDb
      def load(data)
        arr = data ? data : []
        arr.map{|obj| obj.is_a?(::Hash) ? OpenStruct.new(obj) : obj}
      end
      def to_json;@obj.map(&:to_h).to_json end
    end

    # describe OpenStructArray do
    #   before do
    #     @model = OpenStructArray.new_by_key('open_struct_array_test', :model)
    #     @file = OpenStructArray.new_by_key('open_struct_array_test', :file)
    #   end

    #   it "can work" do
    #     [@model, @file].each do |arr|
    #       arr.clear
    #       arr.length.must_equal(0)
    #       arr << OpenStruct.new(name: 'a')
    #       arr[0].name.must_equal('a')
    #       arr.push(OpenStruct.new(name: 'b'))
    #       arr[1].name.must_equal('b')
    #       arr.unshift(OpenStruct.new(name: 'c'))
    #       arr[0].name.must_equal('c')
    #       arr.reload
    #       arr.length.must_equal(3)
    #       arr.delete(OpenStruct.new(name: 'b'))
    #       arr.length.must_equal(2)
    #       arr.replace([])
    #       arr.length.must_equal(0)
    #     end
    #   end
    # end
  end
end
