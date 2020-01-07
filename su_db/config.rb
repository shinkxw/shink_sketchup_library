module SHINK_LIBRARY
  module SuDb
    class Config < BaseDb
      def load(data);OpenStruct.new(data ? data : {}) end
      def method_missing(m, *args, &block)
        result = @obj.send(m, *args, &block)
        save if m.to_s.include?('=')
        result
      end
      def to_json;@obj.to_h.to_json end
    end

    # describe Config do
    #   before do
    #     @model = Config.new_by_key('config_test', :model)
    #     @file = Config.new_by_key('config_test', :file)
    #   end

    #   it "can set value" do
    #     [@model, @file].each do |config|
    #       rand_num1 = rand(100)
    #       rand_num2 = rand(100)
    #       config.a = rand_num1
    #       config.b = rand_num2
    #       config.reload
    #       config.a.must_equal(rand_num1)
    #       config.b.must_equal(rand_num2)
    #     end
    #   end
    # end
  end
end
