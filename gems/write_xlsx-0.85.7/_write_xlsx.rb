# -*- coding: utf-8 -*-

require 'tmpdir'
require 'tempfile'
require 'digest/md5'

module Shink::BaseLibrary
  module Writexlsx
    Zip = Shink::BaseLibrary::Zip
    Writexlsx = self
  end

  dir = "#{File.dirname(__FILE__)}/_write_xlsx"
  Sketchup::require "#{dir}/package/xml_writer_simple"
  Sketchup::require "#{dir}/col_name"
  Sketchup::require "#{dir}/utility"
  Sketchup::require "#{dir}/package/app"
  Sketchup::require "#{dir}/format"
  Sketchup::require "#{dir}/package/comments"
  Sketchup::require "#{dir}/package/content_types"
  Sketchup::require "#{dir}/package/core"
  Sketchup::require "#{dir}/package/relationships"
  Sketchup::require "#{dir}/package/shared_strings"
  Sketchup::require "#{dir}/package/styles"
  Sketchup::require "#{dir}/package/table"
  Sketchup::require "#{dir}/package/theme"
  Sketchup::require "#{dir}/package/vml"
  Sketchup::require "#{dir}/package/packager"
  Sketchup::require "#{dir}/sheets"
  Sketchup::require "#{dir}/package/button"
  Sketchup::require "#{dir}/colors"
  Sketchup::require "#{dir}/drawing"
  Sketchup::require "#{dir}/sparkline"
  Sketchup::require "#{dir}/package/conditional_format"
  Sketchup::require "#{dir}/worksheet/cell_data"
  Sketchup::require "#{dir}/worksheet/data_validation"
  Sketchup::require "#{dir}/worksheet/hyperlink"
  Sketchup::require "#{dir}/worksheet/page_setup"
  Sketchup::require "#{dir}/worksheet"
  Sketchup::require "#{dir}/chartsheet"
  Sketchup::require "#{dir}/formats"
  Sketchup::require "#{dir}/shape"
  Sketchup::require "#{dir}/gradient"
  Sketchup::require "#{dir}/chart/caption"
  Sketchup::require "#{dir}/chart/axis"
  Sketchup::require "#{dir}/chart/series"
  Sketchup::require "#{dir}/chart"
  Sketchup::require "#{dir}/zip_file_utils"
  Sketchup::require "#{dir}/workbook"
  Sketchup::require "#{dir}/chart/area"
  Sketchup::require "#{dir}/chart/bar"
  Sketchup::require "#{dir}/chart/column"
  Sketchup::require "#{dir}/chart/pie"
  Sketchup::require "#{dir}/chart/doughnut"
  Sketchup::require "#{dir}/chart/line"
  Sketchup::require "#{dir}/chart/radar"
  Sketchup::require "#{dir}/chart/scatter"
  Sketchup::require "#{dir}/chart/stock"

  class WriteXLSX < Writexlsx::Workbook
  end

  class WriteXLSXInsufficientArgumentError < StandardError
  end

  class WriteXLSXDimensionError < StandardError
  end

  class WriteXLSXOptionParameterError < StandardError
  end
end
