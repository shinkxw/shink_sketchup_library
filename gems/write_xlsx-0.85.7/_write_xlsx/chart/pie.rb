# -*- coding: utf-8 -*-
###############################################################################
#
# Pie - A class for writing Excel Pie charts.
#
# Used in conjunction with Chart.
#
# See formatting note in Chart.
#
# Copyright 2000-2011, John McNamara, jmcnamara@cpan.org
# Convert to ruby by Hideo NAKAMURA, cxn03651@msj.biglobe.ne.jp
#

module Shink::BaseLibrary::Writexlsx
  class Chart
    # A Pie chart doesn't have an X or Y axis so the following common chart
    # methods are ignored.
    #
    #     chart.set_x_axis
    #     chart.set_y_axis
    #
    class Pie < self
      include Writexlsx::Utility

      def initialize(subtype)
        super(subtype)
        @vary_data_color = 1
        @rotation        = 0

        # Set the available data label positions for this chart type.
        @label_position_default = 'best_fit'
        @label_positions = {
          'center'      => 'ctr',
          'inside_base' => 'inBase',
          'inside_end'  => 'inEnd',
          'outside_end' => 'outEnd',
          'best_fit'    => 'bestFit'
        }
      end

      #
      # Override parent method to add a warning.
      #
      def combine(chart)
        raise "Combined chart not currently supported for Pie charts"
      end

      #
      # Set the Pie/Doughnut chart rotation: the angle of the first slice.
      #
      def set_rotation(rotation)
        return unless rotation
        if rotation >= 0 && rotation <= 360
          @rotation = rotation
        else
          raise "Chart rotation $rotation outside range: 0 <= rotation <= 360"
        end
      end

      #
      # Override the virtual superclass method with a chart specific method.
      #
      def write_chart_type
        # Write the c:areaChart element.
        write_pie_chart
      end

      #
      # Write the <c:pieChart> element. Over-ridden method to remove axis_id code
      # since pie charts don't require val and vat axes.
      #
      def write_pie_chart
        @writer.tag_elements('c:pieChart') do
          # Write the c:varyColors element.
          write_vary_colors
          # Write the series elements.
          @series.each {|s| write_series(s)}
          # Write the c:firstSliceAng element.
          write_first_slice_ang
        end
      end

      #
      # Over-ridden method to remove the cat_axis() and val_axis() code since
      # Pie/Doughnut charts don't require those axes.
      #
      # Write the <c:plotArea> element.
      #
      def write_plot_area
        @writer.tag_elements('c:plotArea') do
          # Write the c:layout element.
          write_layout(@plotarea.layout, 'plot')
          # Write the subclass chart type element.
          write_chart_type
        end
      end

      #
      # Over-ridden method to add <c:txPr> to legend.
      #
      # Write the <c:legend> element.
      #
      def write_legend
        position = @legend_position
        allowed  = %w(right left top bottom)
        delete_series = @legend_delete_series || []

        if @legend_position =~ /^overlay_/
          position = @legend_position.sub(/^overlay_/, '')
          overlay = true
        else
          position = @legend_position
          overlay = false
        end

        return if position == 'none'
        return unless allowed.include?(position)

        @writer.tag_elements('c:legend') do
          # Write the c:legendPos element.
          write_legend_pos(position[0])
          # Remove series labels from the legend.
          # Write the c:legendEntry element.
          delete_series.each { |index| write_legend_entry(index) }
          # Write the c:layout element.
          write_layout(@legend_layout, 'legend')
          # Write the c:overlay element.
          write_overlay if overlay
          # Write the c:txPr element. Over-ridden.
          write_tx_pr_legend(0, @legend_font)
        end
      end

      #
      # Write the <c:txPr> element for legends.
      #
      def write_tx_pr_legend(horiz, font)
        rotation = nil
        if ptrue?(font) && font[:_rotation]
          rotation = font[:_rotation]
        end

        @writer.tag_elements('c:txPr') do
          # Write the a:bodyPr element.
          write_a_body_pr(rotation, horiz)
          # Write the a:lstStyle element.
          write_a_lst_style
          # Write the a:p element.
          write_a_p_legend(font)
        end
      end

      #
      # Write the <a:p> element for legends.
      #
      def write_a_p_legend(font)
        @writer.tag_elements('a:p') do
          # Write the a:pPr element.
          write_a_p_pr_legend(font)
          # Write the a:endParaRPr element.
          write_a_end_para_rpr
        end
      end

      #
      # Write the <a:pPr> element for legends.
      #
      def write_a_p_pr_legend(font)
        @writer.tag_elements('a:pPr', [ ['rtl', 0] ]) do
          # Write the a:defRPr element.
          write_a_def_rpr(font)
        end
      end

      #
      # Write the <c:varyColors> element.
      #
      def write_vary_colors
        @writer.empty_tag('c:varyColors', [ ['val', 1] ])
      end

      #
      # Write the <c:firstSliceAng> element.
      #
      def write_first_slice_ang
        @writer.empty_tag('c:firstSliceAng', [ ['val', @rotation] ])
      end
    end
  end
end
