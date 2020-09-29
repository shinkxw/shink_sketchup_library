# -*- coding: utf-8 -*-

module Writexlsx
  class Chart
    class Caption
      attr_accessor :name, :formula, :data_id, :name_font
      attr_reader :layout, :overlay, :none

      def initialize(chart)
        @chart = chart
      end

      def merge_with_hash(params) # :nodoc:
        @name, @formula = @chart.process_names(params[:name], params[:name_formula])
        @data_id        = @chart.data_id(@formula, params[:data])
        @name_font      = @chart.convert_font_args(params[:name_font])
        @layout   = @chart.layout_properties(params[:layout], 1)

        # Set the title overlay option.
        @overlay  = params[:overlay]

        # Set the no automatic title option.
        @none = params[:none]
      end
    end
  end
end
